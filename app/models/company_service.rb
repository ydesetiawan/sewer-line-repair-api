class CompanyService < ApplicationRecord
  # Associations
  belongs_to :company
  belongs_to :service_category

  # Validations
  validates :service_category_id, uniqueness: { scope: :company_id }
end
