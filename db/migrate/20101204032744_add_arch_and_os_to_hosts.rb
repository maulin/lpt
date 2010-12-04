class AddArchAndOsToHosts < ActiveRecord::Migration
  def self.up
    add_column :hosts, :arch, :string
    add_column :hosts, :os, :string
  end

  def self.down
    remove_column :hosts, :os
    remove_column :hosts, :arch
  end
end
