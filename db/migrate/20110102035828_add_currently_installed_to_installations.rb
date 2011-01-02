class AddCurrentlyInstalledToInstallations < ActiveRecord::Migration
  def self.up
    add_column :installations, :currently_installed, :boolean, :default => 1
  end

  def self.down
    remove_column :installations, :currently_installed
  end
end
