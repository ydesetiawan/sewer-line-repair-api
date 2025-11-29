class AddWorkingHoursToCompanies < ActiveRecord::Migration[8.1]
  def change
    add_column :companies, :working_hours, :jsonb
  end
end

