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

ActiveRecord::Schema[8.0].define(version: 2026_01_26_010533) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "appointments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "slot_id", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slot_id"], name: "index_appointments_on_slot_id"
    t.index ["user_id"], name: "index_appointments_on_user_id"
  end

  create_table "calendars", force: :cascade do |t|
    t.string "name", null: false
    t.string "timezone", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_calendars_on_user_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "razorpay_payment_id"
    t.string "razorpay_order_id"
    t.integer "amount"
    t.string "currency"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "razorpay_signature"
    t.string "type", default: "PaymentMethod::Razorpay"
    t.string "gateway_transaction_id"
    t.string "gateway_order_id"
    t.jsonb "gateway_data", default: {}
    t.index ["gateway_order_id"], name: "index_payment_methods_on_gateway_order_id"
    t.index ["gateway_transaction_id"], name: "index_payment_methods_on_gateway_transaction_id"
    t.index ["type"], name: "index_payment_methods_on_type"
    t.index ["user_id"], name: "index_payment_methods_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "appointment_id", null: false
    t.bigint "payment_method_id"
    t.integer "amount", null: false
    t.string "currency", default: "INR"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_payments_on_appointment_id"
    t.index ["payment_method_id"], name: "index_payments_on_payment_method_id"
    t.index ["status"], name: "index_payments_on_status"
  end

  create_table "role_users", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_role_users_on_role_id"
    t.index ["user_id"], name: "index_role_users_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "slots", force: :cascade do |t|
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.integer "status", default: 0, null: false
    t.bigint "calendar_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_id"], name: "index_slots_on_calendar_id"
    t.index ["start_at", "end_at"], name: "index_slots_on_start_at_and_end_at"
    t.index ["status"], name: "index_slots_on_status"
  end

  create_table "user_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "profile_picture"
    t.string "bio"
    t.string "location"
    t.jsonb "professional_info", default: {}
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uid"
    t.string "provider"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "appointments", "slots"
  add_foreign_key "appointments", "users"
  add_foreign_key "calendars", "users"
  add_foreign_key "payment_methods", "users"
  add_foreign_key "payments", "appointments"
  add_foreign_key "payments", "payment_methods"
  add_foreign_key "role_users", "roles"
  add_foreign_key "role_users", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "slots", "calendars"
  add_foreign_key "user_profiles", "users"
end
