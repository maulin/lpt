class Version < ActiveRecord::Base

  has_many :installations
  has_many :packages, :through => :installations
  has_many :packages, :through => :installables

  validates_uniqueness_of :name
  
  def to_s
    name
  end  

end
