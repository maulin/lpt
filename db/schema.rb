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

ActiveRecord::Schema.define(:version => 20101202041232) do

  create_table "arches", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "arches", ["name"], :name => "index_arches_on_name"

  create_table "hosts", :force => true do |t|
    t.string   "name"
    t.string   "running_kernel"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hosts", ["name"], :name => "index_hosts_on_name"

  create_table "installations", :force => true do |t|
    t.integer  "host_id",      :null => false
    t.integer  "package_id",   :null => false
    t.integer  "version_id",   :null => false
    t.integer  "release_id",   :null => false
    t.integer  "arch_id",      :null => false
    t.integer  "os_id",        :null => false
    t.datetime "installed_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "installations", ["arch_id"], :name => "index_installations_on_arch_id"
  add_index "installations", ["host_id", "os_id"], :name => "index_installations_on_host_id_and_os_id"
  add_index "installations", ["host_id", "package_id"], :name => "index_installations_on_host_id_and_package_id"
  add_index "installations", ["host_id"], :name => "index_installations_on_host_id"
  add_index "installations", ["os_id"], :name => "index_installations_on_os_id"
  add_index "installations", ["package_id"], :name => "index_installations_on_package_id"
  add_index "installations", ["version_id", "package_id"], :name => "index_installations_on_version_id_and_package_id"
  add_index "installations", ["version_id"], :name => "index_installations_on_version_id"

  create_table "os", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "os", ["name"], :name => "index_os_on_name"

  create_table "packages", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "packages", ["name"], :name => "index_packages_on_name"

  create_table "releases", :force => true do |t|
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "releases", ["value"], :name => "index_releases_on_value"

  create_table "versions", :force => true do |t|
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "versions", ["value"], :name => "index_versions_on_value"

end
