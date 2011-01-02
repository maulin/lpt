require 'rubygems'
require 'net/ssh'

class ScanHosts

  @queue = :ssh_host

  def self.perform(hostname)
    TIMEOUT=30
    puts "starting perform"
    pkgs = ""
    host_arch = ""
    running_kernel = ""
    host_os = ""
    user = "test"
    password = "1q2w3e"
    
    begin
      Net::SSH.start(hostname, user, :password => password) do |ssh|
        puts "ssh successful"
        
        begin
          timeout(TIMEOUT) do
            ssh.exec!("rpm -qa --qf \"%{name}===%{version}===%{release}===%{arch}===%{INSTALLTIME:date}==SPLIT==\"") do |channel, stream, data|
              if stream == :stderr
                Rails.logger.info "RPM command error: #{data}"
                puts "rpm error!"
                exit 1
              else            
                pkgs << data
              end
            end
          end
        rescue Timeout::Error
          Rails.logger.info "RPM command timeout."
          puts "rpm timeout"
          exit 1
        end
        
        begin
          timeout(TIMEOUT) do
            ssh.exec!("uname -m") do |channel, stream, data|
              if stream == :stderr
                Rails.logger.info "Arch command error: #{data}"
                exit 1
              else        
                host_arch << data
              end
            end
          end
        rescue Timeout::Error
          Rails.logger.info "Arch command timeout."
          puts "arch timeout"
          exit 1
        end

        begin
          timeout(TIMEOUT) do
            ssh.exec!("uname -r") do |channel, stream, data|
              if stream == :stderr
                Rails.logger.info "Running Kernel command error: #{data}"
                exit 1
              else        
                running_kernel << data
              end
            end
          end
        rescue Timeout::Error
          Rails.logger.info "running_kernel command timeout."
          puts "running kernel timeout"
          exit 1
        end          

        begin
        timeout(TIMEOUT) do
          ssh.exec!("test -f /etc/redhat-release && cat /etc/redhat-release") do |channel, stream, data|
            if stream == :stderr
              Rails.logger.info "Host OS command error: #{data}"
              exit 1
            else        
              host_os << data
            end
          end
        end
        rescue Timeout::Error
          Rails.logger.info "Host os command timeout."
          puts "host os timeout"
          exit 1
        end  
        
      end #end ssh block
    rescue Net::SSH::Exception => e
      Rails.logger.info "Fatal: Could not ssh as #{user} to #{hostname}."
      exit 1
    end
    Installation.import(hostname, pkgs, host_os, host_arch, running_kernel)
  end #end perform
  
end
