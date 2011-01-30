class Repo < ActiveRecord::Base
  has_many :hosts, :through => :sources
  has_many :sources
  has_many :installables
  has_many :packages, :through => :installables
  
  validates_uniqueness_of :url

  def self.import(hostname, import_params)
    host = Host.find_by_name(hostname)
    repos = import_params["yum_repos"].split(/^$/)

    repos.each do |repo|
      rep=repo.split("\n")
      rep_hash = {}

      rep.each do |r|
          next if !r.match(/Repo-/)
          line=r.split(":",2)
          #rep_hash[line[0].sub(/:$/,"").strip.chomp] = line[1..-1].join(" ").sub(/^:/,"").strip.chomp
          rep_hash[line[0].strip.chomp] = line[1..-1].join(" ").strip.chomp
      end

      enabled = 0      
      enabled = 1 if (rep_hash["Repo-status"] =~ /.*enabled.*/)
      type = ""

      if rep_hash.has_key?("Repo-metalink")
        found = Repo.find_or_create_by_url(rep_hash["Repo-metalink"])
        type = "Repo-metalink"
      elsif rep_hash.has_key?("Repo-mirrors")
        found = Repo.find_or_create_by_url(rep_hash["Repo-mirrors"])
        type = "Repo-mirrors"
      elsif rep_hash.has_key?("Repo-baseurl")
        found = Repo.find_or_create_by_url(rep_hash["Repo-baseurl"])
        type = "Repo-baseurl"
      end

      if rep_hash.has_key?("Repo-name")
        if found
          found.update_attributes(:name => rep_hash["Repo-name"], :repo_type => type)

          if source = Source.where(:host_id => host.id, :repo_id => found.id).first
            source.update_attributes(:enabled => enabled)
          else
            Source.create(:host_id => host.id, :repo_id => found.id, :enabled => enabled)
          end
          
        end
      end
      
    end # end repos.each
  end # end import method
  
  def to_s
    name
  end  

  def to_param
    name
  end

end
