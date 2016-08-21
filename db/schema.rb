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

ActiveRecord::Schema.define(version: 20160820165631) do

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "provider",   limit: 255
    t.string   "uid",        limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "partner_links", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "link",       limit: 255
    t.string   "use_for",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "partner_links", ["user_id"], name: "index_partner_links_on_user_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.string   "last_name",              limit: 255
    t.date     "birthday"
    t.integer  "sex",                    limit: 4
    t.string   "country",                limit: 255
    t.string   "city",                   limit: 255
    t.string   "about",                  limit: 255
    t.string   "avatar",                 limit: 255
    t.string   "ancestry",               limit: 255
    t.integer  "role_id",                limit: 8
    t.integer  "parent_id",              limit: 8
    t.integer  "status_id",              limit: 8
    t.integer  "security_id",            limit: 8
    t.integer  "referral_code",          limit: 4
    t.string   "phone",                  limit: 255
    t.string   "skype",                  limit: 255
    t.string   "vk",                     limit: 255
    t.string   "fb",                     limit: 255
    t.string   "ok",                     limit: 255
    t.string   "youtube",                limit: 255
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "identities", "users"
  add_foreign_key "partner_links", "users"
end
