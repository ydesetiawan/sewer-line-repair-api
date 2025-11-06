class Country < ApplicationRecord
  # Associations
  has_many :states, dependent: :destroy
  has_many :cities, through: :states

  # Validations
  validates :name, presence: true
  validates :code, presence: true, format: { with: /\A[A-Z]{2}\z/, message: "must be 2 uppercase letters" }, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  # Callbacks
  before_validation :generate_slug

  private

  def generate_slug
    self.slug = name.parameterize if name.present? && slug.blank?
  end
end
