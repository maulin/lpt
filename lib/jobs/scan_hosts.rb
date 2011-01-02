require 'rubygems'
require 'net/ssh'

class ScanHosts

  @queue = :ssh_host
  TIMEOUT=90
  @@import_params = {}
  @@import_params["pkgs"] = ""
  @@import_params["host_arch"] = ""
  @@import_params["running_kernel"] = ""
  @@import_params["host_os"] = ""
  @@user = "test"
  @@password = "1q2w3E"


  def self.perform(hostname)
    Rails.logger.info "Starting perform for ScanHosts(#{hostname})"
    
    begin
      Net::SSH.start(hostname, @@user, :password => @@password) do |ssh|
        timeout(TIMEOUT) do
          ssh.exec!("uname -a") 
        end # end timeout
      end # end ssh block
      Rails.logger.info "SSH test successful for #{hostname} with user=#{@@user}."
      puts "SSH test successful for #{hostname} with user=#{@@user}."
    rescue Net::SSH::Exception => e
      Rails.logger.info "Fatal: Could not ssh as #{@@user} to #{hostname}."
      puts "Fatal: Could not ssh as #{@@user} to #{hostname}."
      exit 1
    end

    do_ssh(hostname, "rpm -qa --qf \"%{name}===%{version}===%{release}===%{arch}===%{INSTALLTIME:date}==SPLIT==\"","pkgs")

    # use one ssh exec for two things
    do_ssh(hostname, "uname -mr","host_arch") 

    @@import_params["running_kernel"]=@@import_params["host_arch"].split[0]
    @@import_params["host_arch"]=@@import_params["host_arch"].split[1]

    do_ssh(hostname, "test -f /etc/redhat-release && cat /etc/redhat-release","host_os") 

    Installation.import(hostname, @@import_params)
    Rails.logger.info "Finish perform for ScanHosts(#{hostname})"
  end #end perform

  def self.do_ssh(hostname, command, import_params_key)
    begin
      Net::SSH.start(hostname, @@user, :password => @@password) do |ssh|
        begin
          timeout(TIMEOUT) do
            ssh.exec!(command) do |channel, stream, data|
              if stream == :stderr
                Rails.logger.info "The ssh command: #{command} had an error!"
                puts "The ssh command: #{command} had an error!"
                exit 1
              else
                @@import_params[import_params_key] << data
              end # End if
            end # End ssh.exec
          end # End timeout
        rescue
          Rails.logger.info "The ssh command: #{command} timed-out!"
          puts "The ssh command: #{command} timed-out!"
          exit 1
        end # End begin/rescue
      end # End SSH.start
    rescue Net::SSH::Exception => e
      Rails.logger.info "The ssh command: #{command} had an error!"
      puts "The ssh command: #{command} had an error!"
      exit 1
    end

  end # end do_ssh
  
end
