class AddTypeToRepo < ActiveRecord::Migration
  def self.up
    add_column :repos, :repo_type, :string
  end

  def self.down
    remove_column :repos, :repo_type
  end
end