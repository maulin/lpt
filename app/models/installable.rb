require 'xml'

class Installable < ActiveRecord::Base
  belongs_to :package
  belongs_to :repo
  belongs_to :arch
  belongs_to :version 
  
  def self.import(repo, primary)
    p = XML::Reader.file(primary.path)
    while p.read do
      if p.name == "package"
        pkg, a, v, r = ""
        details = XML::Reader.string("<package>" + p.read_inner_xml + "</package>")
        next if p.node_type == 15 #end element
        while details.read do
          if details.name == "name"
            pkg = details.read_string.chomp.strip
            details.next
          end
          if details.name == "arch"
            a = details.read_string.chomp.strip
            details.next
          end      
          if details.name == "version" 
            details.move_to_attribute("ver")
            v = details.value.chomp.strip
            details.move_to_attribute("rel")
            r = details.value.chomp.strip
          end
        end#end while details
        package = Package.find_or_create_by_name(pkg)
        version = Version.find_or_create_by_name(v + "-" + r)
        arch = Arch.find_or_create_by_name(a)
        
        unless i = Installable.where(:repo_id => repo.id,
                                     :package_id => package.id,
                                     :arch_id => arch.id,
                                     :version_id => version.id).first
          
          Installable.create(:repo_id => repo.id,
                            :package_id => package.id,
                            :arch_id => arch.id,
                            :version_id => version.id)
        end#end unless
        
        puts "#{pkg} - #{v}-#{r} - #{a}"
      end# end if package

    end#end while p
    
  end#end import
  
end#end class
