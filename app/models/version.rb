class Version < ActiveRecord::Base
  has_many :installations, :dependent => :destroy
  has_many :packages, :through => :installations, :uniq => true
  has_many :hosts, :through => :installations, :uniq => true
  has_many :oss, :through => :installations, :uniq => true
  has_many :releases, :through => :installations, :uniq => true
  validates_uniqueness_of :value
  validates_format_of :value, :with => /\A(\S+\s?)+\Z/, :message => "can't be blank or contain trailing white space"

  def to_s
    value
  end
end
