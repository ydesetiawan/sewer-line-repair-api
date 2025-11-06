class ServiceCategory < ApplicationRecord
  # Associations
  has_many :company_services, dependent: :destroy
  has_many :companies, through: :company_services

  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  # Callbacks
  before_validation :generate_slug

  private

  def generate_slug
    self.slug = name.parameterize if name.present? && slug.blank?
  end
end
