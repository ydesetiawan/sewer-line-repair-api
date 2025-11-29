class CreateCertifications < ActiveRecord::Migration[8.1]
  def change
    create_table :certifications do |t|
      t.string :company_id, limit: 255, null: false, index: true
      t.string :certification_name, null: false
      t.string :issuing_organization
      t.date :issue_date
      t.date :expiry_date
      t.string :certificate_number
      t.string :certificate_url

      t.timestamps
    end

    add_index :certifications, :expiry_date
    add_foreign_key :certifications, :companies, column: :company_id, primary_key: :id
  end
end
