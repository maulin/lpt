class AddVersionIdArchIdToInstallations < ActiveRecord::Migration
  def self.up
    add_column :installations, :version_id, :integer
    add_column :installations, :arch_id, :integer
  end

  def self.down
    remove_column :installations, :version_id
    remove_column :installations, :arch_id
  end
end
