class Installable < ActiveRecord::Base
  belongs_to :package
  belongs_to :repo 
end
