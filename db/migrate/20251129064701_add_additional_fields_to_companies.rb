class AddAdditionalFieldsToCompanies < ActiveRecord::Migration[8.1]
  def change
    add_column :companies, :about, :jsonb
    add_column :companies, :subtypes, :text
    add_column :companies, :logo_url, :string
    add_column :companies, :booking_appointment_link, :string
    add_column :companies, :borough, :string
  end
end
