class AddHostidToHosts < ActiveRecord::Migration
  def self.up
    add_column :hosts, :hostid, :string
  end

  def self.down
    remove_column :hosts, :hostid, :string
  end
end
