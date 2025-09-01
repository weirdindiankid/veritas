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

ActiveRecord::Schema[7.2].define(version: 2025_09_01_162757) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "archives", force: :cascade do |t|
    t.bigint "document_id", null: false
    t.integer "version"
    t.bigint "previous_archive_id"
    t.string "checksum"
    t.text "diff_content"
    t.string "archived_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_id"], name: "index_archives_on_document_id"
    t.index ["previous_archive_id"], name: "index_archives_on_previous_archive_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "domain"
    t.string "terms_url"
    t.string "privacy_url"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "documents", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "url"
    t.string "title"
    t.text "content"
    t.datetime "archived_at"
    t.string "ipfs_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_documents_on_company_id"
  end

  add_foreign_key "archives", "archives", column: "previous_archive_id"
  add_foreign_key "archives", "documents"
  add_foreign_key "documents", "companies"
end
