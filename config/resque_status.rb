# run resque-web like so:
# <RAILS_LIB_PATH>/bin/resque-web <RAILS_APP>/config/resque_status.rb
# Then the resque-web UI will have an additional tab "Statuses"
require 'resque/status_server'
