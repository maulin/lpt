class Installation < ActiveRecord::Base
  belongs_to :host
  belongs_to :package
  belongs_to :version
  belongs_to :release
  belongs_to :os
  belongs_to :arch

  def self.import(pkgs, host, os, arch, running_kernel)
    os = Os.find_or_create_by_name(os)
    host = Host.find_by_name(host)
    host.update_attributes(:running_kernel => running_kernel.chomp.strip)
    pkgs = pkgs.split("==SPLIT==")
    new_pkgs = []
    puts "#{host.id} #{os.id} #{pkgs[0]}"
    pkgs.each do |pkg|
      pkg, version, release, arch, installed_on = pkg.split("===").map{|s| s.chomp.strip}
      #unless install=Installation.first(:joins => [:package, :version, :release, :arch],
      #          :conditions => {:host_id => host.id, 
      #                          :os_id => os.id, 
      #                          :packages => {:name => pkg},
      #                          :versions => {:value => version}, 
      #                          :releases => {:value => release}, 
      #                          :arches => {:name => arch}})
      unless install=Installation.joins(:package, :version, :release, :arch).where(:host_id => 2,
                                                                            :os_id => 1,
                                                                            :packages => {:name => "libdmapsharing"},
                                                                            :versions => {:value => "1.9.0.21"},
                                                                            :releases => {:value => "1.fc14"},
                                                                            :arches => {:name => "i686"} ).first
        new_pkgs += pkg.to_a
        p_id = Package.find_or_create_by_name(pkg).id
        v_id = Version.find_or_create_by_value(version).id
        r_id = Release.find_or_create_by_value(release).id
        a_id = Arch.find_or_create_by_name(arch).id
        
        t = Time.parse(installed_on)
        #Rails.logger.info "Aaaaaaarch #{a_id.name}"
        Installation.create(:host_id => host.id, 
                           :package_id => p_id, 
                           :version_id => v_id,
                           :release_id => r_id,
                           :arch_id => a_id, 
                           :os_id => os.id,
                           :installed_on => t)
      end # enc unless Installation
    end # end pkgs.each do
  end # end self.import
end
