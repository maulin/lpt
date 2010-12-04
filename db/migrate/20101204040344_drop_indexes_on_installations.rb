class DropIndexesOnInstallations < ActiveRecord::Migration
  def self.up
    remove_index :installations, :host_id
    remove_index :installations, :package_id
    remove_index :installations, :version_id
    remove_index :installations, :os_id
    remove_index :installations, :arch_id
    remove_index :installations, [:host_id, :package_id]
    remove_index :installations, [:host_id, :os_id]
    remove_index :installations, [:version_id, :package_id]
  end

  def self.down
  end
end
