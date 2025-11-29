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

ActiveRecord::Schema[8.1].define(version: 2025_11_22_055437) do
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

  create_table "certifications", force: :cascade do |t|
    t.string "certificate_number"
    t.string "certificate_url"
    t.string "certification_name", null: false
    t.string "company_id", limit: 255, null: false
    t.datetime "created_at", null: false
    t.date "expiry_date"
    t.date "issue_date"
    t.string "issuing_organization"
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_certifications_on_company_id"
    t.index ["expiry_date"], name: "index_certifications_on_expiry_date"
  end

  create_table "cities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "name", null: false
    t.string "slug", null: false
    t.bigint "state_id", null: false
    t.datetime "updated_at", null: false
    t.index ["latitude", "longitude"], name: "index_cities_on_latitude_and_longitude"
    t.index ["state_id", "slug"], name: "index_cities_on_state_id_and_slug", unique: true
    t.index ["state_id"], name: "index_cities_on_state_id"
  end

  create_table "companies", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.decimal "average_rating", precision: 3, scale: 2, default: "0.0"
    t.boolean "background_checked", default: false
    t.boolean "certified_partner", default: false
    t.bigint "city_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "email"
    t.boolean "insured", default: false
    t.decimal "latitude", precision: 10, scale: 6
    t.boolean "licensed", default: false
    t.decimal "longitude", precision: 10, scale: 6
    t.string "name", null: false
    t.string "phone"
    t.boolean "service_guarantee", default: false
    t.string "service_level"
    t.string "slug", null: false
    t.string "specialty"
    t.string "street_address"
    t.integer "total_reviews", default: 0
    t.datetime "updated_at", null: false
    t.boolean "verified_professional", default: false
    t.string "website"
    t.jsonb "working_hours"
    t.string "zip_code"
    t.index ["average_rating"], name: "index_companies_on_average_rating"
    t.index ["city_id", "slug"], name: "index_companies_on_city_id_and_slug", unique: true
    t.index ["city_id"], name: "index_companies_on_city_id"
    t.index ["latitude", "longitude"], name: "index_companies_on_latitude_and_longitude"
    t.index ["name"], name: "index_companies_on_name"
  end

  create_table "company_services", force: :cascade do |t|
    t.string "company_id", limit: 255, null: false
    t.datetime "created_at", null: false
    t.bigint "service_category_id", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "service_category_id"], name: "index_company_services_unique", unique: true
    t.index ["company_id"], name: "index_company_services_on_company_id"
    t.index ["service_category_id"], name: "index_company_services_on_service_category_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "code", limit: 2, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_countries_on_code", unique: true
    t.index ["slug"], name: "index_countries_on_slug", unique: true
  end

  create_table "gallery_images", force: :cascade do |t|
    t.string "company_id", limit: 255, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "image_type"
    t.integer "position", default: 0, null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["company_id", "position"], name: "index_gallery_images_on_company_id_and_position"
    t.index ["company_id"], name: "index_gallery_images_on_company_id"
    t.index ["image_type"], name: "index_gallery_images_on_image_type"
  end

  create_table "reviews", force: :cascade do |t|
    t.string "company_id", limit: 255, null: false
    t.datetime "created_at", null: false
    t.integer "rating", null: false
    t.date "review_date", null: false
    t.text "review_text"
    t.string "reviewer_name", null: false
    t.datetime "updated_at", null: false
    t.boolean "verified", default: false
    t.index ["company_id", "review_date"], name: "index_reviews_on_company_id_and_review_date"
    t.index ["company_id"], name: "index_reviews_on_company_id"
    t.index ["rating"], name: "index_reviews_on_rating"
    t.check_constraint "rating >= 1 AND rating <= 5", name: "rating_range"
  end

  create_table "service_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_service_categories_on_slug", unique: true
  end

  create_table "states", force: :cascade do |t|
    t.string "code", limit: 10, null: false
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id", "code"], name: "index_states_on_country_id_and_code"
    t.index ["country_id", "slug"], name: "index_states_on_country_id_and_slug", unique: true
    t.index ["country_id"], name: "index_states_on_country_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "certifications", "companies"
  add_foreign_key "cities", "states"
  add_foreign_key "companies", "cities"
  add_foreign_key "company_services", "companies"
  add_foreign_key "company_services", "service_categories"
  add_foreign_key "gallery_images", "companies"
  add_foreign_key "reviews", "companies"
  add_foreign_key "states", "countries"
end
