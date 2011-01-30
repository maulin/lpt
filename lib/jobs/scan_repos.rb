require 'rubygems'
require 'xml'
require 'open-uri'
require 'zlib'
require 'resque/job_with_status'

class ScanRepos < Resque::JobWithStatus

  def perform
    at(1,3,"Starting perform...")
    url = options["url"]
    repo = Repo.find_by_url(url)
    puts "Repo-type = #{repo.repo_type}"
    if repo.repo_type == "Repo-metalink"
      get_mirrors(repo)
    end
    completed "Finished scanning repo.name"
  end#end perform
  
  def get_mirrors(repo)
    at(2,3,"Getting mirrors...")
    metalink = open("#{RAILS_ROOT}/lib/metalink.#{Time.now.to_i}.xml", "w+")  
    repomd = open("#{RAILS_ROOT}/lib/repomd.#{Time.now.to_i}.xml", "w+")
    repomd_url = ""
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
        repomd_url = m.read_string
        begin
          repomd.write(open(repomd_url).read)
          repomd.close
        rescue
          puts "Error getting file from #{repomd_url}"
          puts "Trying the next mirror..."
          r.next    
        else
          puts "Success!"
          puts "Using repomd file from #{repomd_url}"
          break
        end
      end
    end#End while
    
    process_repomd(repo, repomd, repomd_url)
    File.delete(metalink.path, repomd.path)
    
  end#end get_mirrors
  
  def process_repomd(repo, repomd, repomd_url)
    at(3,3,"Processing repomd...")
    if File.zero?(repomd.path)
      failed("Repomd file is empty...Exiting.")
      exit 1
    else
      r = XML::Reader.file(repomd.path)
      while r.read do
        if r.name == "data"
          r.move_to_attribute("type")
          if r.value == "primary"
            checksum = ""
            location = ""
            r.move_to_element
            info = XML::Reader.string("<data>" + r.read_inner_xml + "</data>")
            while info.read do
              if info.name == "checksum"
                checksum = info.read_string
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
          
      if location.empty? || checksum.empty?
        failed("Could not find location or checksum of primary package list")
        exit 1
      else
        if repo.sha == checksum
          completed("#{repo}: Checksums match, no change since last scan.")
        else
          package_list_url = repomd_url.gsub(/repodata.*/, location)
          begin
            open("#{RAILS_ROOT}/lib/primary.#{Time.now.to_i}.xml", 'w+') do |primary|
              open(package_list_url) do |remote_file|
                primary.write(Zlib::GzipReader.new(remote_file).read)
              end
            end
          rescue
            failed("Could not get primary.xml.gz")
            exit 1
          end
        end
      end
    end#if size zero
    puts "end repomd"
  end#end process_repomd
  
end#end class



























