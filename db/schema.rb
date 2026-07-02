# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_02_210346) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "multipliers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.float "value", default: 1.0, null: false
  end

  create_table "notes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "message"
    t.datetime "read_at"
    t.bigint "task_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["task_id"], name: "index_notifications_on_task_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "task_integrations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_id", null: false
    t.bigint "task_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_integration_id", null: false
    t.index ["external_id"], name: "index_task_integrations_on_external_id", unique: true
    t.index ["task_id"], name: "index_task_integrations_on_task_id"
    t.index ["user_integration_id"], name: "index_task_integrations_on_user_integration_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.boolean "completed"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "estimated_minutes", default: 0
    t.bigint "multiplier_id"
    t.string "recurrence", default: "none", null: false
    t.datetime "schedule_at", precision: nil
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["multiplier_id"], name: "index_tasks_on_multiplier_id"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "time_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "duration_minutes", default: 0, null: false
    t.bigint "task_id", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_time_entries_on_task_id"
  end

  create_table "user_integrations", force: :cascade do |t|
    t.string "access_token"
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "provider", null: false
    t.string "refresh_token"
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["provider", "uid"], name: "index_user_integrations_on_provider_and_uid", unique: true
    t.index ["user_id", "provider"], name: "index_user_integrations_on_user_id_and_provider", unique: true
    t.index ["user_id"], name: "index_user_integrations_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "notes", "users"
  add_foreign_key "notifications", "tasks"
  add_foreign_key "notifications", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "task_integrations", "tasks"
  add_foreign_key "task_integrations", "user_integrations"
  add_foreign_key "tasks", "multipliers"
  add_foreign_key "tasks", "users"
  add_foreign_key "time_entries", "tasks"
  add_foreign_key "user_integrations", "users"
end
