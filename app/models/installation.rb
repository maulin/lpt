class Installation < ActiveRecord::Base
  belongs_to :host
  belongs_to :package
  belongs_to :arch
  belongs_to :version
  
  def self.import(host, pkgs, host_os, host_arch, running_kernel)
    puts "INSIDE INSTALLATION"
    host_os = Os.find_or_create_by_name(host_os)
    puts host_os
    host_arch = Arch.find_or_create_by_name(host_arch)
    puts host_arch
    host = Host.find_by_name(host)
    puts host
    host.update_attributes(:running_kernel => running_kernel.chomp.strip,
                            :arch_id => host_arch.id,
                            :os_id => host_os.id)

    pkgs = pkgs.split("==SPLIT==")
    new_pkgs = []

    pkgs.each do |pkg|
      pkg, version, release, arch, installed_on = pkg.split("===").map{|s| s.chomp.strip}
      version = "#{version}-#{release}"
      p_id = Package.find_or_create_by_name(pkg).id
      v_id = Version.find_or_create_by_name(version).id
      a_id = Arch.find_or_create_by_name(arch).id
      
      unless install=Installation.where(:host_id => host.id,
                                        :package_id => p_id,
                                        :version_id => v_id,
                                        :arch_id => a_id).first
        new_pkgs += pkg.to_a

        t = Time.parse(installed_on)
        Installation.create(:host_id => host.id, 
                           :package_id => p_id, 
                           :version_id => v_id,
                           :arch_id => a_id, 
                           :installed_on => t)
      end # end unless Installation
    end # end pkgs.each do
  end # end self.import
  
end
