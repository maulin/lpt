require 'rubygems'
require 'xml'
require 'open-uri'
require 'zlib'
require 'resque/job_with_status'

class ScanRepos < Resque::JobWithStatus

  def perform
    at(1,4,"Starting perform...")
    metalink = Tempfile.new("metalink.xml", "#{Rails.root.to_s}/tmp")
    repomd = Tempfile.new("repomd.xml", "#{Rails.root.to_s}/tmp")
    primary = Tempfile.new("primary.xml", "#{Rails.root.to_s}/tmp")
    repomd_url = ""
    primary_sha = ""
    url = options["url"]
    repo = Repo.find_by_url(url)
    
    if repo.repo_type == "Repo-metalink"
      get_mirrors(repo, metalink, repomd, repomd_url)
      process_repomd(repo, repomd, repomd_url, primary, primary_sha)
      at(4,4, "Starting import...")
      Installable.import(repo, primary)
      at(4,4, "Finished import...")      
    elsif repo.repo_type == "Repo-baseurl"
      #TODO
    elsif repo.repo_type == "Repo-mirrors"
      #TODO      
    end
    metalink.close; repomd.close; primary.close
    repo.sha = primary_sha
    repo.save
    completed("Finished scanning #{repo.name}")
  end#end perform
  
  def get_mirrors(repo, metalink, repomd, repomd_url)
    at(2,4,"Getting mirrors...")
    begin
      metalink.write(open(repo.url).read)
      metalink.close
    rescue
      failed("Could not get mirror list from #{repo.name} - #{repo.url}")
      exit 1
    end    
    
    m = XML::Reader.file(metalink.path)
    while m.read do
      if m.name == "url"
        repomd_url.replace  m.read_string
        begin
          repomd.write(open(repomd_url).read)
          repomd.close
        rescue
          at(2,4,"Error getting repomd file from #{repomd_url}")
          at(2,4,"Trying the next mirror...")
          r.next    
        else
          at(2,4,"Using repomd file from #{repomd_url}")
          break
        end
      end
    end#End while
    
  end#end get_mirrors
  
  def process_repomd(repo, repomd, repomd_url, primary, primary_sha)
    at(3,4,"Processing repomd...")
    if File.zero?(repomd.path)
      failed("Repomd file is empty...Exiting.")
      exit 1
    else
      r = XML::Reader.file(repomd.path)
      while r.read do
        if r.name == "data"
          r.move_to_attribute("type")
          if r.value == "primary"
            location = ""
            r.move_to_element
            info = XML::Reader.string("<data>" + r.read_inner_xml + "</data>")
            while info.read do
              if info.name == "checksum"
                 primary_sha.replace info.read_string
                info.next
              end
              if info.name == "location"
                info.move_to_attribute("href")
                location = info.value
              end
            end
            break
          end#end if primary
          
        end#End if data
      end#End while
          
      if location.empty? || primary_sha.empty?
        failed("Could not find location or checksum of primary package list")
        exit 1
      else
        if repo.sha == primary_sha
          completed("#{repo}: Checksums match, no change since last scan.")
          exit 0
        else
          package_list_url = repomd_url.gsub(/repodata.*/, location)
          begin
            open(package_list_url) do |remote_file|
              primary.write(Zlib::GzipReader.new(remote_file).read)
            end
            primary.close
          rescue
            failed("Could not get primary.xml.gz")
            exit 1
          end
        end
      end
    end#if size zero

  end#end process_repomd
  
end#end class



























