class CreateHosts < ActiveRecord::Migration
  def self.up
    create_table :hosts do |t|
      t.string :name
      t.string :running_kernel

      t.timestamps
    end
    add_index :hosts, :name
  end

  def self.down
    drop_table :hosts
  end
end
