class Arch < ActiveRecord::Base

  has_many :installations
  has_many :packages, :through => :installations
  has_many :installables
  has_many :packages, :through => :installables
  has_many :hosts
  
  validates_uniqueness_of :name
  
  def to_s
    name
  end  
  
end
