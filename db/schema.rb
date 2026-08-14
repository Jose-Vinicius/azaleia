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

ActiveRecord::Schema[8.1].define(version: 2026_08_14_130000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "eqi_profiles", force: :cascade do |t|
    t.integer "assertiveness_score"
    t.string "assessment_id"
    t.datetime "created_at", null: false
    t.integer "emotional_expression_score"
    t.integer "emotional_self_awareness_score"
    t.integer "empathy_score"
    t.integer "flexibility_score"
    t.integer "happiness_score"
    t.datetime "imported_at"
    t.integer "impulse_control_score"
    t.integer "independence_score"
    t.integer "interpersonal_relationships_score"
    t.boolean "is_valid", default: true
    t.integer "optimism_score"
    t.integer "problem_solving_score"
    t.integer "reality_testing_score"
    t.integer "self_actualization_score"
    t.integer "self_regard_score"
    t.integer "social_responsibility_score"
    t.integer "stress_tolerance_score"
    t.integer "total_eq"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_eqi_profiles_on_user_id", unique: true
  end

  create_table "goals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "psychometric_focus"
    t.text "smart_achievable"
    t.text "smart_measurable"
    t.text "smart_relevant"
    t.text "smart_specific"
    t.text "smart_timebound"
    t.integer "status", default: 1, null: false
    t.date "target_date"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_goals_on_user_id"
  end

  create_table "key_results", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "okr_id", null: false
    t.text "title", null: false
    t.datetime "updated_at", null: false
    t.index ["okr_id"], name: "index_key_results_on_okr_id"
  end

  create_table "mbti_profiles", force: :cascade do |t|
    t.string "assessment_id"
    t.string "auxiliary_function"
    t.datetime "created_at", null: false
    t.string "dominant_function"
    t.decimal "ei_pci", precision: 5, scale: 2
    t.string "ei_winner"
    t.string "final_type", null: false
    t.datetime "imported_at"
    t.string "inferior_function"
    t.decimal "jp_pci", precision: 5, scale: 2
    t.string "jp_winner"
    t.decimal "sn_pci", precision: 5, scale: 2
    t.string "sn_winner"
    t.string "temperament_code"
    t.string "temperament_group"
    t.string "tertiary_function"
    t.decimal "tf_pci", precision: 5, scale: 2
    t.string "tf_winner"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_mbti_profiles_on_user_id", unique: true
  end

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

  create_table "okrs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "quarter", default: "Q3 2026", null: false
    t.integer "status", default: 1, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_okrs_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_projects_on_user_id"
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
    t.bigint "goal_id"
    t.bigint "key_result_id"
    t.bigint "multiplier_id"
    t.bigint "project_id"
    t.string "recurrence", default: "none", null: false
    t.datetime "schedule_at", precision: nil
    t.string "status", default: "pending", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["goal_id"], name: "index_tasks_on_goal_id"
    t.index ["key_result_id"], name: "index_tasks_on_key_result_id"
    t.index ["multiplier_id"], name: "index_tasks_on_multiplier_id"
    t.index ["project_id"], name: "index_tasks_on_project_id"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "eqi_profiles", "users"
  add_foreign_key "goals", "users"
  add_foreign_key "key_results", "okrs"
  add_foreign_key "mbti_profiles", "users"
  add_foreign_key "notes", "users"
  add_foreign_key "notifications", "tasks"
  add_foreign_key "notifications", "users"
  add_foreign_key "okrs", "users"
  add_foreign_key "projects", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "task_integrations", "tasks"
  add_foreign_key "task_integrations", "user_integrations"
  add_foreign_key "tasks", "goals"
  add_foreign_key "tasks", "key_results"
  add_foreign_key "tasks", "multipliers"
  add_foreign_key "tasks", "projects"
  add_foreign_key "tasks", "users"
  add_foreign_key "time_entries", "tasks"
  add_foreign_key "user_integrations", "users"
end
