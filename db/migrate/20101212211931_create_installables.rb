class CreateInstallables < ActiveRecord::Migration
  def self.up
    create_table :installables do |t|
      t.integer :repo_id
      t.integer :package_id
      t.integer :version_id
      t.integer :arch_id
      t.boolean :latest_ind

      t.timestamps
    end
  end

  def self.down
    drop_table :installables
  end
end
