require 'xml'

class Installable < ActiveRecord::Base
  belongs_to :package
  belongs_to :repo
  belongs_to :arch
  belongs_to :version 
  
  def self.import(repo, primary)
    p = XML::Reader.file(primary.path)
    count = 0
    pkg_count = 0
    new_pkg_count = 0
    while p.read do
      if p.name == "package"
        count += 1
        next
      end
      if count.odd?
        if p.name == "name" and p.node_type != 15
          pkg = p.read_string.chomp.strip
          package = Package.find_or_create_by_name(pkg)
        end
        if p.name == "arch" and p.node_type != 15
          a = p.read_string.chomp.strip
          arch = Arch.find_or_create_by_name(a)          
        end      
        if p.name == "version" 
          p.move_to_attribute("ver")
          v = p.value.chomp.strip
          p.move_to_attribute("rel")
          r = p.value.chomp.strip
          version = Version.find_or_create_by_name(v + "-" + r)          
        end
      elsif count > 1 and count.even?
        puts "#{pkg} - #{v}-#{r} - #{a}"
        pkg_count += 1
        unless i = Installable.where(:repo_id => repo.id, :package_id => package.id,
                                     :arch_id => arch.id, :version_id => version.id).first
          new_pkg_count += 1
          Installable.create(:repo_id => repo.id, :package_id => package.id,
                            :arch_id => arch.id, :version_id => version.id)
        end#end unless
      end#end if count
        
    end#end while p
    puts "Total = #{pkg_count} - Installed = #{new_pkg_count}"
  end#end import
  
end#end class
