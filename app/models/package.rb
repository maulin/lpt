class Package < ActiveRecord::Base
  has_many :installations, :dependent => :destroy
  has_many :hosts, :through => :installations, :uniq => true
  validates_uniqueness_of :name
  validates_format_of :name, :with => /\A(\S+\s?)+\Z/, :message => "can't be blank or contain trailing white space"

  def to_s
    name
  end

  # TODO
  #def to_param
  #  "#{id}-#{name}"
  #end
  
  def self.find_uniq_hosts_installed_on
    Package.find_by_sql('select id, name, count(*) host_count 
            from packages, 
            (SELECT distinct package_id, host_id FROM installations) as x 
            where id = x.package_id 
            group by name')
  end

end
