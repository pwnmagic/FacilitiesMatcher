# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20130405095313) do

  create_table "comments", :force => true do |t|
    t.integer  "dhis2_mapping_id"
    t.text     "text"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "dhis2_mapping", :force => true do |t|
    t.string  "mtrac_name"
    t.string  "mtrac_owner"
    t.integer "healthfacilitybase_id"
    t.string  "dhis2_name"
    t.string  "dhis2_owner"
    t.string  "dhis2_uuid"
    t.string  "district"
    t.string  "f_type"
    t.float   "percentage_matched"
    t.boolean "duplicate"
    t.boolean "followup"
    t.boolean "mark_duplicate",        :default => false
    t.boolean "mark_delete",           :default => false
    t.boolean "mark_reprocess",        :default => false
    t.boolean "add_to_dhis2",          :default => false
    t.boolean "error_in_dhis2_data",   :default => false
    t.boolean "reprocessed"
    t.string  "dhis2_f_type"
    t.boolean "already_matched",       :default => false
  end

  create_table "facility_last_reported_dates", :force => true do |t|
    t.integer  "healthfacilitybase_id"
    t.datetime "date"
  end

  create_table "health_facilities", :force => true do |t|
    t.integer "healthfacilitybase_id"
    t.string  "district"
    t.boolean "promoted",              :default => false
    t.string  "name"
  end

end
