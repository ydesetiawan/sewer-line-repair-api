class State < ApplicationRecord
  # Associations
  belongs_to :country
  has_many :cities, dependent: :destroy
  has_many :companies, through: :cities

  # Validations
  validates :name, presence: true
  validates :code, presence: true
  validates :slug, presence: true, uniqueness: { scope: :country_id }

  # Callbacks
  before_validation :generate_slug

  scope :by_country, ->(country_id) { where(country_id: country_id) }

  private

  def generate_slug
    self.slug = name.parameterize if name.present? && slug.blank?
  end
end
