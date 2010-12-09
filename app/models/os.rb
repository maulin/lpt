class Os < ActiveRecord::Base
  
  has_many :hosts
  
  validates_uniqueness_of :name
  
  def to_s
    name
  end  
  
end
