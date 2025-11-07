class City < ApplicationRecord
  # Associations
  belongs_to :state
  has_one :country, through: :state
  has_many :companies, dependent: :destroy
  has_many :company_service_areas, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :state_id }
  validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_nil: true
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_nil: true

  # Callbacks
  before_validation :generate_slug

  # Methods
  def full_name
    "#{name}, #{state.name}, #{state.country.name}"
  end

  private

  def generate_slug
    self.slug = name.parameterize if name.present? && slug.blank?
  end
end
