require 'rubygems'
require 'resque/tasks'

task "resque:setup" => :environment do    
  ActiveRecord::Base.send(:subclasses).each { |klass|  klass.columns }
end

