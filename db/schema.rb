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

ActiveRecord::Schema.define(version: 2022_01_13_184838) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

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
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "cnpj", limit: 18
    t.integer "status", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.bigint "plan_id"
    t.string "plan_status", default: "off"
    t.string "pagarme_subscription_id"
    t.integer "available_words", default: 0
    t.integer "words"
    t.date "last_words_updated"
    t.integer "total_translated", default: 0
    t.string "street"
    t.string "street_line_2"
    t.integer "street_number"
    t.string "zip_code"
    t.string "neighborhood"
    t.string "city"
    t.string "state"
    t.string "phone"
    t.string "country"
    t.index ["plan_id"], name: "index_companies_on_plan_id"
    t.index ["user_id"], name: "index_companies_on_user_id"
  end

  create_table "document_glossaries", force: :cascade do |t|
    t.bigint "document_id", null: false
    t.bigint "glossary_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["document_id"], name: "index_document_glossaries_on_document_id"
    t.index ["glossary_id"], name: "index_document_glossaries_on_glossary_id"
  end

  create_table "documents", force: :cascade do |t|
    t.text "original_text"
    t.text "translated_text"
    t.integer "status", default: 0
    t.bigint "company_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "title"
    t.bigint "user_id", null: false
    t.boolean "was_translated", default: false
    t.string "source"
    t.string "target"
    t.string "rich_original"
    t.index ["company_id"], name: "index_documents_on_company_id"
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "glossaries", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "name"
    t.string "language_1"
    t.string "language_2"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_glossaries_on_company_id"
  end

  create_table "packages", force: :cascade do |t|
    t.string "name"
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "BRL", null: false
    t.integer "words"
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "plans", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.string "pagarme_id"
    t.integer "price"
    t.integer "days"
    t.integer "trial_days"
    t.integer "charges"
    t.integer "installments"
    t.integer "invoice_reminder"
    t.integer "words"
    t.integer "status", default: 0, null: false
    t.boolean "include_review", default: false
  end

  create_table "terms", force: :cascade do |t|
    t.bigint "glossary_id", null: false
    t.string "source"
    t.string "target"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["glossary_id"], name: "index_terms_on_glossary_id"
  end

  create_table "text_chunks", force: :cascade do |t|
    t.string "original"
    t.string "translated"
    t.integer "status", default: 2
    t.bigint "document_id", null: false
    t.bigint "responsible_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "order"
    t.text "rich_translated"
    t.index ["document_id"], name: "index_text_chunks_on_document_id"
    t.index ["responsible_id"], name: "index_text_chunks_on_responsible_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "pagarme_id"
    t.string "status"
    t.bigint "company_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_transactions_on_company_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "role"
    t.bigint "company_id"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "first_name"
    t.string "last_name"
    t.boolean "admin", default: false
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "companies", "plans"
  add_foreign_key "companies", "users"
  add_foreign_key "document_glossaries", "documents"
  add_foreign_key "document_glossaries", "glossaries"
  add_foreign_key "documents", "companies"
  add_foreign_key "documents", "users"
  add_foreign_key "glossaries", "companies"
  add_foreign_key "terms", "glossaries"
  add_foreign_key "text_chunks", "documents"
  add_foreign_key "text_chunks", "users", column: "responsible_id"
  add_foreign_key "transactions", "companies"
  add_foreign_key "users", "companies"
end
