class Source < ActiveRecord::Base
  belongs_to :host
  belongs_to :repo
end
