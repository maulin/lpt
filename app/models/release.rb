class Release < ActiveRecord::Base
  has_many :installations, :dependent => :destroy
  has_many :versions, :through => :installations, :uniq => true
  validates_uniqueness_of :value
  validates_format_of :value, :with => /\A(\S+\s?)+\Z/, :message => "can't be blank or contain trailing white space"

  def to_s
    value
  end
end
