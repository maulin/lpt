class Repo < ActiveRecord::Base
  has_and_belongs_to_many :hosts
  has_many :installables
  has_many :packages, :through => :installables
end
