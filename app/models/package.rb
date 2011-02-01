class Package < ActiveRecord::Base

  has_many :installations, :dependent => :destroy
  has_many :hosts, :through => :installations, :uniq => true
  has_many :arches, :through => :installations
  has_many :versions, :through => :installations
  has_many :installables
  has_many :repos, :through => :installables
  
  validates_uniqueness_of :name
  validates_format_of :name, :with => /\A(\S+\s?)+\Z/, :message => "can't be blank or contain trailing white space"
  
  search_methods :pkg_hosts
  
  scope :pkg_hosts, Package.select('packages.id, name, count(host_id) as host_count').joins( \
                   ',(select distinct package_id, host_id from installations where currently_installed = 1)as x').where( \
                   'x.package_id = id').group('name, package_id')

  def to_s
    name
  end

  def to_param
    name
  end

end
