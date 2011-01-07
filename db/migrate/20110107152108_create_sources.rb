class CreateSources < ActiveRecord::Migration
  def self.up
    create_table :sources do |t|
      t.column :host_id, :integer
      t.column :repo_id, :integer
      t.column :enabled, :boolean

      t.timestamps
    end
  end

  def self.down
    drop_table :sources
  end
end
