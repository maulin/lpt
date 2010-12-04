class AddArchOsVersionToInstallations < ActiveRecord::Migration
  def self.up
    add_column :installations, :arch, :string
    add_column :installations, :os, :string
    add_column :installations, :version, :string
  end

  def self.down
    remove_column :installations, :version
    remove_column :installations, :os
    remove_column :installations, :arch
  end
end
