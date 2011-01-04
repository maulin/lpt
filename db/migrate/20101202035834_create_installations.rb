class CreateInstallations < ActiveRecord::Migration
  def self.up
    create_table :installations do |t|
      t.references :host, :null => false
      t.references :package, :null => false
      t.references :version, :null => false
      t.references :arch, :null => false
      t.timestamp :installed_on

      t.timestamps
    end

    add_index :installations, :host_id
    add_index :installations, :package_id
    add_index :installations, :version_id
    add_index :installations, :arch_id
    add_index :installations, [:host_id, :package_id]
    add_index :installations, [:version_id, :package_id]
  end

  def self.down
    drop_table :installations
  end
end
