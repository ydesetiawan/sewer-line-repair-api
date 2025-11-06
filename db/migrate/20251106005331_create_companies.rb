class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.references :city, null: false, foreign_key: true, index: true
      t.string :name, null: false
      t.string :slug, null: false
      t.string :phone
      t.string :email
      t.string :website
      t.string :street_address
      t.string :zip_code
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.string :specialty
      t.string :service_level
      t.text :description
      t.decimal :average_rating, precision: 3, scale: 2, default: 0
      t.integer :total_reviews, default: 0
      t.boolean :verified_professional, default: false
      t.boolean :certified_partner, default: false
      t.boolean :licensed, default: false
      t.boolean :insured, default: false
      t.boolean :background_checked, default: false
      t.boolean :service_guarantee, default: false

      t.timestamps
    end

    add_index :companies, [:city_id, :slug], unique: true
    add_index :companies, :average_rating
    add_index :companies, :name
  end
end
