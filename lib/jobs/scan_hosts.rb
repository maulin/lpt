require 'rubygems'
require 'net/ssh'

class ScanHosts

  @queue = :ssh_host

  def self.perform(hostname)
    pkgs = ""
    puts "pks = #{pkgs}"
    host_arch = ""
    running_kernel = ""
    host_os = ""
    user = "test"
    password = "1q2w3e"
    
    begin
      Net::SSH.start(hostname, user, :password => password) do |ssh|
        puts "ssh successful"
        ssh.exec!("rpm -qa --qf \"%{name}===%{version}===%{release}===%{arch}===%{INSTALLTIME:date}==SPLIT==\"") do |channel, stream, data|
          pkgs << data
        end
        puts "got pkgs #{pkgs.size}"
        ssh.exec!("uname -m") do |channel, stream, data|
          host_arch << data
        end
        puts "got host arch #{host_arch}"
        ssh.exec!("uname -r") do |channel, stream, data|
          running_kernel << data
        end
        puts "got kernel #{running_kernel}"
        ssh.exec!("test -f /etc/redhat-release && cat /etc/redhat-release") do |channel, stream, data|
          host_os << data
        end
        puts "got host os #{host_os}"
      end
    rescue Net::SSH::Exception => e
      Rails.logger.info "Fatal: Could not ssh as #{user} to #{hostname}."
      exit 1
    end
    Installation.import(hostname, pkgs, host_os, host_arch, running_kernel)
  end #end perform
  
end
