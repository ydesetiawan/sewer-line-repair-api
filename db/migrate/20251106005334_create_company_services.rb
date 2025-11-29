class CreateCompanyServices < ActiveRecord::Migration[8.1]
  def change
    create_table :company_services do |t|
      t.string :company_id, limit: 255, null: false, index: true
      t.references :service_category, null: false, foreign_key: true, index: true

      t.timestamps
    end

    add_index :company_services, [:company_id, :service_category_id], unique: true, name: "index_company_services_unique"
    add_foreign_key :company_services, :companies, column: :company_id, primary_key: :id
  end
end
