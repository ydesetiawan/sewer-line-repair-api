class CreateCompanyServiceAreas < ActiveRecord::Migration[8.1]
  def change
    create_table :company_service_areas do |t|
      t.string :company_id, limit: 255, null: false, index: true
      t.references :city, null: false, foreign_key: true, index: true

      t.timestamps
    end

    add_index :company_service_areas, [:company_id, :city_id], unique: true
    add_foreign_key :company_service_areas, :companies, column: :company_id, primary_key: :id
  end
end
