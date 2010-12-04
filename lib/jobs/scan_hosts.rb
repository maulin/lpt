require 'rubygems'
require 'net/ssh'

class ScanHosts

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
        ssh.exec!("rpm -qa --qf  \"%{name}===%{version}-%{release}===%{arch}===%{INSTALLTIME:date}==SPLIT==\"") do |channel, stream, data|
          pkgs << data
        end
        ssh.exec!("uname -m") do |channel, stream, data|
          host_arch << data
        end
        ssh.exec!("uname -r") do |channel, stream, data|
          running_kernel << data
        end
        ssh.exec!("test -f /etc/redhat-release && cat /etc/redhat-release") do |channel, stream, data|
          host_os << data
        end
      end 
    Rails.logger.info "Trying to add #{pkgs} for #{hostname}"
    rescue Net::SSH::Exception => e
      Rails.logger.info "Fatal: Could not ssh as #{user} to #{hostname}."
      exit 1
    end
    Installation.import(pkgs,hostname,host_os,host_arch,running_kernel)
  end #end perform
end
