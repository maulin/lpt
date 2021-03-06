require 'rubygems'
require 'net/ssh'
require 'resque/job_with_status'

class ScanHosts < Resque::JobWithStatus
 
  TIMEOUT=90
  COMMANDS = {}
  COMMANDS["1-red_hat_rpm"] = "rpm -qa --qf \"%{name}===%{version}===%{release}===%{arch}===%{INSTALLTIME:date}==SPLIT==\""
  COMMANDS["2-host_arch_kernel"] = "uname -mr"
  COMMANDS["3-red_hat_os"] = "test -f /etc/redhat-release && cat /etc/redhat-release"
  COMMANDS["4-yum_repo_list"] = "yum repolist all -v"
  CMD_NAMES = COMMANDS.keys.sort
 
  #@queue = :ssh_host
  @@user = "test"
  @@password = "1q2w3e"
 
  def exec_command(ssh, name, command)
    output = ""
    begin
      timeout(TIMEOUT) do
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
      
        at(1,3,"Running commands...")  
        import_params["pkgs"] = exec_command(ssh, CMD_NAMES[0], COMMANDS["1-red_hat_rpm"])
        import_params["running_kernel"], import_params["host_arch"] = exec_command(ssh, CMD_NAMES[1], COMMANDS["2-host_arch_kernel"]).split
        import_params["host_os"] = exec_command(ssh, CMD_NAMES[2], COMMANDS["3-red_hat_os"])
        import_params["yum_repos"] = exec_command(ssh, CMD_NAMES[3], COMMANDS["4-yum_repo_list"])
        
        at(2, 3, "Importing installations...")
        Installation.import(hostname, import_params)
        at(3, 3, "Importing repos...")
        Repo.import(hostname, import_params)

        completed("Finished scanning #{hostname}.")
      end
    rescue Net::SSH::Exception
      failed("Fatal: Could not ssh as #{@@user} to #{hostname}.")
      exit 1
    end #end ssh begin
  end #end perform
 
end #end ScanHosts
