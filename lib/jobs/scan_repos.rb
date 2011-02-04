require 'rubygems'
require 'xml'
require 'open-uri'
require 'zlib'
require 'resque/job_with_status'

class ScanRepos < Resque::JobWithStatus

  def perform
    at(1,6,"Starting perform...")
    url = options["url"]
    repo = Repo.find_by_url(url)    
    if repo.repo_type == "Repo-metalink"
      metalink = get_metalink_file(repo)
      repomd = get_repomd_data(metalink)
      primary_attrs = get_primary_attrs(repomd["file"])
      if primary_attrs["sha"] == repo.sha
        completed("Checksum match, nothing has changed since the last scan.")
        exit 0
      else
        primary = get_primary(repomd["url"], primary_attrs["location"])
        at(6,6,"Starting import...")
        Installable.import(repo, primary)
        metalink.delete; repomd["file"].delete; primary.delete
        repo.sha = primary_attrs["sha"]
        repo.save
        completed("Finished scanning #{repo.name}")
        exit 0
      end
    elsif repo.repo_type == "Repo-baseurl"
      #TODO
    elsif repo.repo_type == "Repo-mirrors"
      #TODO      
    end
  end#end perform
  
  #returns the metalink from from the repos url
  def get_metalink_file(repo)
    at(2,6,"Getting metalink file...")
    metalink = Tempfile.new("metalink.xml", "#{Rails.root.to_s}/tmp")
    begin
      metalink.write(open(repo.url).read)
    rescue Exception => e
      failed("Could not get mirror list from #{repo.name} - #{repo.url} because of #{e}")
      exit 1
    end
    metalink    
  end#end get_metalink_file
  
  #returns a hash containing the temporary repomd file and the url of the files location
  def get_repomd_data(metalink)
    at(3,6,"getting repomd file...")
    repomd = { "file" => Tempfile.new( "repomd.xml", "#{Rails.root.to_s}/tmp" ) }
    repomd["url"] = ""
    begin
      m = XML::Reader.file(metalink.path)
    rescue Exception => e
      failed("XML parse error - metalink file because of #{e}")
      exit 1
    end
    while m.read do
      if m.name == "url"
        repomd["url"] = m.read_string
        begin
          repomd["file"].write(open(repomd["url"]).read)
        rescue Exception => e
          at(3,6,"Error = #{e}")
          at(3,6,"Trying the next mirror...")
          m.next    
        else
          at(3,6,"Using repomd file from #{repomd["url"]}")
          break
        end
      end
    end#End while
    unless File.size(repomd["file"].path) == 0
      repomd
    else
      failed("Repomd file is empty.")
      exit 1    
    end
  end#end get_repomd_file
  
  #returs a hash with the sha and location of the primary packages file
  def get_primary_attrs(repomd)
    at(4,6,"getting primary attributes...")
    primary_attrs = {}
    begin
      r = XML::Reader.file(repomd.path)
    rescue Exception => e
      failed("XML parse error - repomd file because of #{e}")
      exit 1
    end
    while r.read do
      if r.name == "data" and r.node_type != 15
        r.move_to_attribute("type")
        if r.value == "primary"
          attrs = XML::Reader.string(r.read_outer_xml)
          while attrs.read do
            if attrs.name == "checksum" and attrs.node_type != 15
              primary_attrs["sha"] = attrs.read_string
            end
            if attrs.name == "location"
              attrs.move_to_attribute("href")
              primary_attrs["location"] = attrs.value
            end
          end#end while attrs
          break
        end
      end#end if data      
    end#end while
    primary_attrs
  end#end get_primary_attrs
  
  #returns the primary xml file
  def get_primary(url, location)
    at(5,6,"getting primary xml file...")
    primary = Tempfile.new("primary.xml", "#{Rails.root.to_s}/tmp")
    package_list_url = url.gsub(/repodata.*/, location)
    begin
      open(package_list_url) do |remote_file|
        primary.write(Zlib::GzipReader.new(remote_file).read)
      end
      primary.close
    rescue Exception => e
      failed("Could not get primary.xml.gz because of #{e}")
      exit 1
    end    
    primary
  end#end get_primary
  
end#end class

