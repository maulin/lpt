class Os < ActiveRecord::Base
  has_many :installations
  has_many :packages, :through => :installations, :uniq => true
  has_many :hosts, :through => :installations, :uniq => true
  has_many :archs, :through => :installations, :uniq => true
  validates_uniqueness_of :name
  validates_format_of :name, :with => /\A(\S+\s?)+\Z/, :message => "can't be blank or contain trailing white space"

  def to_s
    name
  end
end
