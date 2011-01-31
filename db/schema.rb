# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110131015938) do

  create_table "arches", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hosts", :force => true do |t|
    t.string   "name"
    t.string   "running_kernel"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "os_id"
    t.integer  "arch_id"
    t.string   "hostid"
    t.string   "rpm_md5"
  end

  add_index "hosts", ["name"], :name => "index_hosts_on_name"

  create_table "installables", :force => true do |t|
    t.integer  "repo_id"
    t.integer  "package_id"
    t.integer  "version_id"
    t.integer  "arch_id"
    t.string   "latest_ind"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "installations", :force => true do |t|
    t.integer  "host_id",                               :null => false
    t.integer  "package_id",                            :null => false
    t.integer  "version_id",                            :null => false
    t.integer  "arch_id",                               :null => false
    t.datetime "installed_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "currently_installed", :default => true
  end

  add_index "installations", ["arch_id"], :name => "index_installations_on_arch_id"
  add_index "installations", ["host_id", "package_id"], :name => "index_installations_on_host_id_and_package_id"
  add_index "installations", ["host_id"], :name => "index_installations_on_host_id"
  add_index "installations", ["package_id"], :name => "index_installations_on_package_id"
  add_index "installations", ["version_id", "package_id"], :name => "index_installations_on_version_id_and_package_id"
  add_index "installations", ["version_id"], :name => "index_installations_on_version_id"

  create_table "oses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "packages", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "packages", ["name"], :name => "index_packages_on_name"

  create_table "repos", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "repo_type"
    t.string   "sha"
  end

  create_table "sources", :force => true do |t|
    t.integer  "host_id"
    t.integer  "repo_id"
    t.boolean  "enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
