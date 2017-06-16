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

ActiveRecord::Schema.define(version: 20170216021751) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "inscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "tournament_id"
    t.integer  "present_position"
    t.integer  "present_round"
    t.integer  "score"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["tournament_id"], name: "index_inscriptions_on_tournament_id", using: :btree
    t.index ["user_id"], name: "index_inscriptions_on_user_id", using: :btree
  end

  create_table "matches", force: :cascade do |t|
    t.integer  "tournament_id"
    t.integer  "n_players",               default: 0,     null: false
    t.integer  "expected_number_players"
    t.integer  "round"
    t.integer  "pyramidal_position"
    t.date     "date"
    t.string   "location"
    t.boolean  "validated",               default: false, null: false
    t.integer  "consumer_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.index ["consumer_id"], name: "index_matches_on_consumer_id", using: :btree
    t.index ["tournament_id"], name: "index_matches_on_tournament_id", using: :btree
  end

  create_table "tournaments", force: :cascade do |t|
    t.string   "name",                          null: false
    t.integer  "number_players",                null: false
    t.string   "prize",                         null: false
    t.integer  "entrance_fee",                  null: false
    t.date     "date",                          null: false
    t.integer  "status",         default: 0,    null: false
    t.integer  "board_size",     default: 4,    null: false
    t.integer  "mode",           default: 0,    null: false
    t.integer  "rounds"
    t.integer  "current_round",  default: 0
    t.boolean  "must_end_round", default: true, null: false
    t.integer  "registered",     default: 0,    null: false
    t.integer  "officer_id",                    null: false
    t.json     "structure"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["officer_id"], name: "index_tournaments_on_officer_id", using: :btree
  end

  create_table "user_matches", force: :cascade do |t|
    t.integer  "user_id",                               null: false
    t.integer  "match_id",                              null: false
    t.integer  "vp"
    t.integer  "elo_general"
    t.integer  "elo_general_change",    default: 0,     null: false
    t.integer  "elo_free"
    t.integer  "elo_free_change",       default: 0,     null: false
    t.integer  "elo_tournament"
    t.integer  "elo_tournament_change", default: 0,     null: false
    t.integer  "tournament_point"
    t.integer  "victory_position"
    t.boolean  "validated",             default: false, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.index ["match_id"], name: "index_user_matches_on_match_id", using: :btree
    t.index ["user_id"], name: "index_user_matches_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "name",                                  null: false
    t.integer  "elo_general",            default: 1500, null: false
    t.integer  "elo_free",               default: 1500, null: false
    t.integer  "elo_tournament",         default: 1500, null: false
    t.integer  "position_general",       default: -1,   null: false
    t.integer  "position_free",          default: -1,   null: false
    t.integer  "position_tournament",    default: -1,   null: false
    t.integer  "matches_played",         default: 0,    null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "inscriptions", "tournaments"
  add_foreign_key "inscriptions", "users"
  add_foreign_key "matches", "matches", column: "consumer_id"
  add_foreign_key "matches", "tournaments"
  add_foreign_key "tournaments", "users", column: "officer_id"
  add_foreign_key "user_matches", "matches"
  add_foreign_key "user_matches", "users"
end
