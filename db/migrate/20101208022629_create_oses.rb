class CreateOses < ActiveRecord::Migration
  def self.up
    create_table :oses do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :oses
  end
end
