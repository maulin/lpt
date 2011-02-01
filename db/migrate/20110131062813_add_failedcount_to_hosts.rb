class AddFailedcountToHosts < ActiveRecord::Migration
  def self.up
    add_column :hosts, :failed_scans, :integer
  end

  def self.down
    remove_column :hosts, :failed_scans, :integer
  end
end
