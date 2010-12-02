require 'rubygems'
require 'net/ssh'

class ScanHosts
  #def initialize(hostname,user,password)
  #  @hostname = hostname
  #  @user = user
  #  @password = password
  #end

  @queue = :ssh_host

  def self.perform(hostname)
    pkgs=""
    arch=""
    running_kernel=""
    os=""
    user = "test"
    password = "1q2w3e"
    
    begin
      Net::SSH.start(hostname, user, :password => password) do |ssh| 
        stdout = ""
        ssh.exec!("hostname") do |channel, stream, data|
          stdout << data
        end
        ssh.exec!("rpm -qa --qf  \"%{name}===%{version}===%{release}===%{arch}===%{INSTALLTIME:date}==SPLIT==\"") do |channel, stream, data|
          pkgs << data
        end
        ssh.exec!("uname -m") do |channel, stream, data|
          arch << data
        end
        ssh.exec!("uname -r") do |channel, stream, data|
          running_kernel << data
        end
        ssh.exec!("test -f /etc/redhat-release && cat /etc/redhat-release") do |channel, stream, data|
          os << data
        end
      end 
    rescue Net::SSH::Exception => e
      puts "Fatal: Could not ssh as #{user} to #{hostname}."
      exit 1
    end
    Installation.import(pkgs,hostname,os,running_kernel)
  end #end perform
end
