class Installation < ActiveRecord::Base
  belongs_to :host
  belongs_to :package

  def self.import(pkgs, host, host_os, host_arch, running_kernel)
#    os = Os.find_or_create_by_name(os)
    host = Host.find_by_name(host)
    host.update_attributes(:running_kernel => running_kernel.chomp.strip, 
                           :arch => host_arch.chomp.strip
                           :os => host_os.chomp.strip)
    pkgs = pkgs.split("==SPLIT==")
    new_pkgs = []
    all_pkgs_ids = []
    pkgs.each do |pkg|
      pkg, version, arch, installed_on = pkg.split("===").map{|s| s.chomp.strip}
      #unless install=Installation.first(:joins => [:package, :version, :release, :arch],
      #          :conditions => {:host_id => host.id, 
      #                          :os_id => os.id, 
      #                          :packages => {:name => pkg},
      #                          :versions => {:value => version}, 
      #                          :releases => {:value => release}, 
      #                          :arches => {:name => arch}})
      p_id = Package.find_or_create_by_name(pkg).id
      all_pkgs_ids += p_id
      unless install=Installation.joins(:package, :version, :release, :arch).where(:host_id => host.id,
                                                                            :package_id => p_id,
                                                                            :os_id => host_os,
                                                                            :version => version,
                                                                            :arches => arch).first
        new_pkgs += pkg.to_a

        t = Time.parse(installed_on)
        Installation.create(:host_id => host.id, 
                           :package_id => p_id, 
                           :version => version,
                           :arch => arch, 
                           :os => os,
                           :installed_on => t)
      end # end unless Installation
    end # end pkgs.each do
  end # end self.import
end
