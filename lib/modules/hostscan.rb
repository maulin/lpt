module PipmanHostScan
  @@host_scan ||= Redis.new
  def self.add_scan_status(hostname)
    @@host_scan.set hostname, "Scanning"
  end
  def self.return_scan_status(hostname)
    #@@host_scan ||= Redis.new
    @@host_scan.get hostname
  end
  def self.reset_scan_status(hostname)
    #@@host_scan ||= Redis.new
    @@host_scan.del hostname
  end
end
