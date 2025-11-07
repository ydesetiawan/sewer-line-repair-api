class AddLatLongIndexToCompanies < ActiveRecord::Migration[8.1]
  def change
    add_index :companies, [:latitude, :longitude], name: 'index_companies_on_latitude_and_longitude'
  end
end
