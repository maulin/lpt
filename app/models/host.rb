class Host < ActiveRecord::Base
  has_many :installations, :dependent => :destroy
  # bug in dependent => destory, should be fixed in 2.3.6 #2251
  #after_destroy {|record| Installation.delete_all("host_id = #{record.id}")}
  has_many :packages, :through => :installations, :uniq => true
  belongs_to :os
  belongs_to :arch
  has_many :repos, :through => :sources
  has_many :sources

  #The :uniq option removes duplicates in Ruby code, not in the database query. 
  #If you have a large number of duplicates, it might be better to use the :select option to tell the 
  #database to remove duplicates using the DISTINCT keyword :select => "DISTINCT packages.*"

  validates_uniqueness_of :name

  def to_s
    name
  end

  def to_param
    name
  end

end
