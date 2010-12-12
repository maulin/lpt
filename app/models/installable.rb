class Installable < ActiveRecord::Base
  belongs_to :package
  belongs_to :arch
  belongs_to :version  
end
