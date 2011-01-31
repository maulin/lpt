require 'rubygems'
require 'net/ssh'
require 'resque/job_with_status'

class ScanHosts < Resque::JobWithStatus
 
  TIMEOUT=90
  RH_COMMANDS = {}
  RH_COMMANDS["1-hostid"] = "hostid"
  RH_COMMANDS["2-red_hat_rpm"] = "rpm -qa --qf \"%{name}===%{version}===%{release}===%{arch}===%{INSTALLTIME:date}==SPLIT==\""
  RH_COMMANDS["3-host_arch_kernel"] = "uname -mr"
  RH_COMMANDS["4-red_hat_os"] = "test -f /etc/redhat-release && cat /etc/redhat-release"
  RH_COMMANDS["5-yum_repo_list"] = "yum repolist all -v"
  CMD_NAMES = RH_COMMANDS.keys.sort
 
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
    
    if !Resque.redis[hostname].empty?
      Rails.logger.info "ScanHosts: Scan already in progress for #{hostname}"
      puts "ScanHosts: Scan already in progress for #{hostname}"
      completed("Scan already in progress for #{hostname}.")
      exit 0
    else
      Resque.redis[hostname] = "Scanning"
    end

    Rails.logger.info "ScanHosts: Starting perform for ScanHosts(#{hostname})"
    begin
      Net::SSH.start(hostname, @@user, :password => @@password, :timeout => TIMEOUT) do |ssh|
      
        at(1,3,"Running commands...")  
        import_params["hostid"] = exec_command(ssh, CMD_NAMES[0], RH_COMMANDS["1-hostid"])
        import_params["pkgs"] = exec_command(ssh, CMD_NAMES[1], RH_COMMANDS["2-red_hat_rpm"])
        import_params["running_kernel"], import_params["host_arch"] = exec_command(ssh, CMD_NAMES[2], RH_COMMANDS["3-host_arch_kernel"]).split
        import_params["host_os"] = exec_command(ssh, CMD_NAMES[3], RH_COMMANDS["4-red_hat_os"])
        import_params["yum_repos"] = exec_command(ssh, CMD_NAMES[4], RH_COMMANDS["5-yum_repo_list"])
        
        at(2, 3, "Importing installations...")
        Installation.import(hostname, import_params)
        at(3, 3, "Importing repos...")
        Repo.import(hostname, import_params)

        completed("Finished scanning #{hostname}.")
      end
    rescue Net::SSH::Exception
      failed("ScanHosts: Fatal: Could not ssh as #{@@user} to #{hostname}.")
      Resque.redis[hostname] = ""
      exit 1
    end #end ssh begin
  end #end perform
 
end #end ScanHosts
