class AddOsIdAndArchIdToHosts < ActiveRecord::Migration
  def self.up
    add_column :hosts, :os_id, :integer
    add_column :hosts, :arch_id, :integer
  end

  def self.down
    remove_column :hosts, :os_id, :integer
    remove_column :hosts, :arch_id, :integer  
  end
end
