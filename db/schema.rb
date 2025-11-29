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

ActiveRecord::Schema[8.1].define(version: 2025_11_06_005335) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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
    t.jsonb "about", default: {}
    t.decimal "average_rating", precision: 3, scale: 2, default: "0.0"
    t.string "booking_appointment_link"
    t.string "borough"
    t.bigint "city_id", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.string "full_address"
    t.decimal "latitude", precision: 10, scale: 6
    t.string "location_link"
    t.string "logo_url"
    t.decimal "longitude", precision: 10, scale: 6
    t.string "name", null: false
    t.string "phone"
    t.string "postal_code"
    t.string "site"
    t.string "slug", null: false
    t.string "street_address"
    t.text "subtypes", default: [], array: true
    t.string "timezone", default: "UTC"
    t.integer "total_reviews", default: 0
    t.datetime "updated_at", null: false
    t.boolean "verified_professional", default: false
    t.jsonb "working_hours", default: {}
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
    t.datetime "image_datetime_utc"
    t.string "image_url", null: false
    t.string "thumbnail_url"
    t.datetime "updated_at", null: false
    t.string "video_url"
    t.index ["company_id"], name: "index_gallery_images_on_company_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.string "author_image"
    t.string "author_title"
    t.string "company_id", limit: 255, null: false
    t.datetime "created_at", null: false
    t.text "owner_answer"
    t.datetime "owner_answer_timestamp_datetime_utc"
    t.datetime "review_datetime_utc"
    t.text "review_img_urls", default: [], array: true
    t.string "review_link"
    t.integer "review_rating"
    t.text "review_text"
    t.datetime "updated_at", null: false
    t.index ["company_id", "review_datetime_utc"], name: "index_reviews_on_company_id_and_review_datetime_utc"
    t.index ["company_id"], name: "index_reviews_on_company_id"
    t.index ["review_rating"], name: "index_reviews_on_review_rating"
    t.check_constraint "review_rating >= 1 AND review_rating <= 5", name: "rating_range"
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

  add_foreign_key "cities", "states"
  add_foreign_key "companies", "cities"
  add_foreign_key "company_services", "companies"
  add_foreign_key "company_services", "service_categories"
  add_foreign_key "gallery_images", "companies"
  add_foreign_key "reviews", "companies"
  add_foreign_key "states", "countries"
end
