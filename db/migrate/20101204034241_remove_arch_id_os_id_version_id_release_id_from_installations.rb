class RemoveArchIdOsIdVersionIdReleaseIdFromInstallations < ActiveRecord::Migration
  def self.up
    remove_column :installations, :arch_id
    remove_column :installations, :os_id
    remove_column :installations, :version_id
    remove_column :installations, :release_id
  end

  def self.down
    add_column :installations, :os_id, :string
    add_column :installations, :os_id, :string
    add_column :installations, :os_id, :string
    add_column :installations, :os_id, :string
  end
end
