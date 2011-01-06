class Repo < ActiveRecord::Base
  has_and_belongs_to_many :hosts
  has_many :installables
  has_many :packages, :through => :installables

  def self.import(import_params)
    repos=import_params["yum_repos"].split(/^$/)

    repos.each do |repo|
      rep=repo.split("\n")
      rep_hash = {}

      rep.each do |r|
          next if !r.match(/Repo-/)
          line=r.split(":",2)
          #rep_hash[line[0].sub(/:$/,"").strip.chomp] = line[1..-1].join(" ").sub(/^:/,"").strip.chomp
          rep_hash[line[0].strip.chomp] = line[1..-1].join(" ").strip.chomp
      end

      if rep_hash.has_key?("Repo-mirrors")
        found = Repo.find_or_create_by_url(rep_hash["Repo-mirrors"])
      end
      if rep_hash.has_key?("Repo-metalink")
        found = Repo.find_or_create_by_url(rep_hash["Repo-metalink"])
      end
      if rep_hash.has_key?("Repo-baseurl")
        found = Repo.find_or_create_by_url(rep_hash["Repo-baseurl"])
      end
      if rep_hash.has_key?("Repo-name")
        if found
          found.update_attributes(:name => rep_hash["Repo-name"]) if found.name.nil? 
        end
      end

    end # end repos.each
  end # end import method

end
