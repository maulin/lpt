class HostsRepos < ActiveRecord::Migration
  def self.up
    create_table :hosts_repos, :id => false do |t|
      t.integer :host_id
      t.integer :repo_id   
   end
  end

  def self.down
    drop_table :hosts_repos
  end
end
