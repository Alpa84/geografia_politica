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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141014201547) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "circus", force: true do |t|
    t.string   "name"
    t.string   "lat"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "elcircuis", force: true do |t|
    t.string   "name"
    t.string   "lat"
    t.string   "lon"
    t.string   "alt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "opinions", force: true do |t|
    t.text     "mensaje"
    t.text     "autor"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "political_parties", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "public_offices", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schools", force: true do |t|
    t.string   "lat"
    t.string   "lon"
    t.string   "address"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "group"
    t.string   "misplaced"
    t.string   "repet"
    t.integer  "total"
  end

  create_table "sections", force: true do |t|
    t.string   "lat"
    t.string   "lon"
    t.string   "address"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "votes_totals", force: true do |t|
    t.integer  "school_id"
    t.integer  "political_party_id"
    t.integer  "public_office_id"
    t.integer  "votes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes_totals", ["political_party_id"], name: "index_votes_totals_on_political_party_id", using: :btree
  add_index "votes_totals", ["public_office_id"], name: "index_votes_totals_on_public_office_id", using: :btree
  add_index "votes_totals", ["school_id"], name: "index_votes_totals_on_school_id", using: :btree

  create_table "zonas", force: true do |t|
    t.string   "name"
    t.string   "dir"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
