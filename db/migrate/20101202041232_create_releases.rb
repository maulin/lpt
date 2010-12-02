class CreateReleases < ActiveRecord::Migration
  def self.up
    create_table :releases do |t|
      t.string :value

      t.timestamps
    end
    add_index :releases, :value
  end

  def self.down
    drop_table :releases
  end
end
