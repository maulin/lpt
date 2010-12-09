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

ActiveRecord::Schema.define(:version => 20101208030505) do

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
  end

  add_index "hosts", ["name"], :name => "index_hosts_on_name"

  create_table "installations", :force => true do |t|
    t.integer  "host_id",      :null => false
    t.integer  "package_id",   :null => false
    t.datetime "installed_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version_id"
    t.integer  "arch_id"
  end

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

  create_table "versions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
