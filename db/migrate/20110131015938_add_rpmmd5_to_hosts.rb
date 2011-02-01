class AddRpmmd5ToHosts < ActiveRecord::Migration
  def self.up
    add_column :hosts, :rpm_md5, :string
  end

  def self.down
    remove_column :hosts, :rpm_md5, :string
  end
end
