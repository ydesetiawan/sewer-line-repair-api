class CreateCompanyServiceAreas < ActiveRecord::Migration[8.1]
  def change
    create_table :company_service_areas do |t|
      t.references :company, null: false, foreign_key: true, index: true
      t.references :city, null: false, foreign_key: true, index: true

      t.timestamps
    end

    add_index :company_service_areas, [:company_id, :city_id], unique: true
  end
end
