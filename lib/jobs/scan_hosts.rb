require 'rubygems'
require 'net/ssh'
require 'resque/job_with_status'

class ScanHosts < Resque::JobWithStatus
  
  TIMEOUT=90
  COMMANDS = {}
  COMMANDS["1-red_hat_rpm"] = "rpm -qa --qf \"%{name}===%{version}===%{release}===%{arch}===%{INSTALLTIME:date}==SPLIT==\""
  COMMANDS["2-host_arch_kernel"] = "uname -mr"
  COMMANDS["3-red_hat_os"] = "test -f /etc/redhat-release && cat /etc/redhat-release"
  CMD_NAMES = COMMANDS.keys.sort
  
  #@queue = :ssh_host
  @@user = "test"
  @@password = "1q2w3e"
  
  def exec_command(ssh, name, command)
    output = ""
    begin
      timeout(10) do
        ssh.exec!(command) do |channel, stream, data|
          if stream == :stderr
            failed("#{name} error: #{data}")
            exit 1
          else
            output << data
          end
        end
      end
      return output    
    rescue Timeout::Error
      failed("#{name} command timed out")
      exit 1
    end #end exec_command begin        
  end #end exec_commands 
  
  def perform
    import_params = {}
    hostname = options['hostname']

    Rails.logger.info "Starting perform for ScanHosts(#{hostname})"
    begin
      Net::SSH.start(hostname, @@user, :password => @@password, :timeout => TIMEOUT) do |ssh|
        
        import_params["pkgs"] = exec_command(ssh, CMD_NAMES[0], COMMANDS["1-red_hat_rpm"])
        import_params["running_kernel"], import_params["host_arch"] = exec_command(ssh, CMD_NAMES[1], COMMANDS["2-host_arch_kernel"]).split
        import_params["host_os"] = exec_command(ssh, CMD_NAMES[2], COMMANDS["3-red_hat_os"])
        
        Installation.import(hostname, import_params)

        completed("Finished scanning #{hostname}.")
      end
    rescue Net::SSH::Exception
      failed("Fatal: Could not ssh as #{@@user} to #{hostname}.")
      exit 1
    end #end ssh begin
  end #end perform
  
end #end ScanHosts
