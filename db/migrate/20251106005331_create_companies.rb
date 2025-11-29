class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies, id: false do |t|
      t.string :id, limit: 255, primary_key: true, null: false
      t.references :city, null: false, foreign_key: true, index: true
      t.string :borough
      t.string :name, null: false
      t.string :slug, null: false
      t.string :phone
      t.string :email
      t.string :site
      t.string :full_address
      t.string :street_address
      t.string :postal_code
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.decimal :average_rating, precision: 3, scale: 2, default: 0
      t.integer :total_reviews, default: 0
      t.boolean :verified_professional, default: false
      t.jsonb :about, default: {}
      t.text :subtypes, array: true, default: []
      t.jsonb :working_hours , default: {}
      t.string :logo_url
      t.string :booking_appointment_link
      t.string :location_link
      t.string :timezone, default: 'UTC'

      t.timestamps
    end

    add_index :companies, [:city_id, :slug], unique: true
    add_index :companies, :average_rating
    add_index :companies, :name
    add_index :companies, [:latitude, :longitude], name: 'index_companies_on_latitude_and_longitude'
  end
end
