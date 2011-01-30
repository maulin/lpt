class AddShaToRepo < ActiveRecord::Migration
  def self.up
    add_column :repos, :sha, :string
  end

  def self.down
    remove_column :repos, :sha
  end
end
