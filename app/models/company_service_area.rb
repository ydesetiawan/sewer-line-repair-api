class CompanyServiceArea < ApplicationRecord
  # Associations
  belongs_to :company
  belongs_to :city

  # Validations
  validate :prevent_primary_city_in_service_areas

  private

  def prevent_primary_city_in_service_areas
    if city_id == company&.city_id
      errors.add(:city, "cannot be the same as company's primary city")
    end
  end
end
