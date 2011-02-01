require 'rubygems'
require 'net/ssh'
require 'resque/job_with_status'

class ScanHosts < Resque::JobWithStatus
 
  TIMEOUT=90
  RH_COMMANDS = {}
  RH_COMMANDS["0-hostid"] = "hostid"
  RH_COMMANDS["1-rpm_md5"] = "rpm -qa |md5sum"
  RH_COMMANDS["2-red_hat_rpm"] = "rpm -qa --qf \"%{name}===%{version}===%{release}===%{arch}===%{INSTALLTIME:date}==SPLIT==\""
  RH_COMMANDS["3-host_arch_kernel"] = "uname -mr"
  RH_COMMANDS["4-red_hat_os"] = "test -f /etc/redhat-release && cat /etc/redhat-release"
  RH_COMMANDS["5-yum_repo_list"] = "yum repolist all -v"
  CMD_NAMES = RH_COMMANDS.keys.sort
 
  #@queue = :ssh_host
  @@user = "test"
  @@password = "1q2w3e"
 
  def exec_command(ssh, name, command, hostname)
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
      job_failed(hostname,"TIMEOUT")
    end #end exec_command begin
  end #end exec_commands 
 
  def perform
    import_params = {}
    hostname = options['hostname']

    if (PipmanHostScan.return_scan_status(hostname))
      Rails.logger.info "ScanHosts: Scan already in progress for #{hostname}"
      completed("Scan already in progress for #{hostname}.")
    else
      Rails.logger.info "ScanHosts: Starting perform for ScanHosts(#{hostname})"
      begin
        host=Host.find_by_name!(hostname)
        PipmanHostScan.add_scan_status(hostname)
        Net::SSH.start(hostname, @@user, :password => @@password, :timeout => TIMEOUT) do |ssh|
        
          at(1,4,"Running commands...")  
          import_params["hostid"] = exec_command(ssh, CMD_NAMES[0], RH_COMMANDS["0-hostid"],hostname)
          import_params["rpm_md5"] = exec_command(ssh, CMD_NAMES[1], RH_COMMANDS["1-rpm_md5"],hostname).split[0]

          # If packages have not changed, do not do anything
          skip_pkgs = "no"
          if (host.get_rpm_qa_md5(import_params["rpm_md5"]) == 1)
            at(2, 4, "Skipping packages as nothing has changed")
            skip_pkgs = "yes"
          end
          import_params["pkgs"] = exec_command(ssh, CMD_NAMES[2], RH_COMMANDS["2-red_hat_rpm"],hostname) if skip_pkgs == "no"

          import_params["running_kernel"], import_params["host_arch"] = exec_command(ssh, CMD_NAMES[3], RH_COMMANDS["3-host_arch_kernel"],hostname).split
          import_params["host_os"] = exec_command(ssh, CMD_NAMES[4], RH_COMMANDS["4-red_hat_os"],hostname)
          import_params["yum_repos"] = exec_command(ssh, CMD_NAMES[5], RH_COMMANDS["5-yum_repo_list"],hostname)
          
          at(2, 4, "Importing installations and host info...")
          Installation.import(hostname, import_params, skip_pkgs)
          
          at(3, 4, "Importing repos...")
          Repo.import(hostname, import_params)

          host.set_rpm_qa_md5(import_params["rpm_md5"])
          PipmanHostScan.reset_scan_status(hostname)
          completed("Finished scanning #{hostname}. With skip_pkgs=#{skip_pkgs}")
        end
      rescue Errno::ETIMEDOUT
        job_failed(host,"ETIMEDOUT")
      rescue Errno::EHOSTUNREACH
        job_failed(host,"EHOSTUNREACH")
      rescue Errno::ECONNREFUSED
        job_failed(host,"ECONREFUSED")
      rescue Errno::ENETUNREACH
        job_failed(host,"ENETUNREACH")
      rescue Errno::ECONNRESET
        job_failed(host,"ECONNRESET")
      rescue Net::SSH::Exception
        job_failed(host,"SSH EXCEPTION")
      rescue ActiveRecord::RecordNotFound
        job_failed(host,"Host #{hostname} not found!")
      end #end begin ssh
    end # end if (PipmanHostScan.return_scan_status(hostname))  
  end #end perform

  def job_failed(host, err_code)
      failed("ScanHosts: Fatal: Could not ssh as #{@@user} to #{host}: #{err_code} ")
      PipmanHostScan.reset_scan_status(host)
      #Resque.redis[host.name] = nil
      host.increment_failed_scans if !host.nil?
      exit 1
  end
end #end ScanHosts
