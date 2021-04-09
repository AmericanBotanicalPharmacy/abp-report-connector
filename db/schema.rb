# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_04_09_014634) do

  create_table "database_sources", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "db_type"
    t.string "host"
    t.string "database"
    t.string "uuid"
    t.string "username"
    t.string "encrypted_password"
    t.string "port"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id"
    t.string "name"
    t.index ["user_id"], name: "index_database_sources_on_user_id"
  end

  create_table "job_notifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "spreadsheet_job_id", null: false
    t.integer "notify_type"
    t.integer "row_number"
    t.string "emails"
    t.string "phones"
    t.string "message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["spreadsheet_job_id"], name: "index_job_notifications_on_spreadsheet_job_id"
  end

  create_table "spreadsheet_jobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "spreadsheet_id", null: false
    t.integer "row_number"
    t.text "sql"
    t.string "name"
    t.string "target_sheet"
    t.string "db_config"
    t.text "options"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["spreadsheet_id"], name: "index_spreadsheet_jobs_on_spreadsheet_id"
  end

  create_table "spreadsheets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "g_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_spreadsheets_on_user_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.string "sub"
    t.string "google_token"
    t.string "google_refresh_token"
  end

  add_foreign_key "job_notifications", "spreadsheet_jobs"
  add_foreign_key "spreadsheet_jobs", "spreadsheets"
  add_foreign_key "spreadsheets", "users"
end
