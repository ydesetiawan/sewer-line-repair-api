class Company < ApplicationRecord
  # Geocoding
  geocoded_by :full_address
  after_validation :geocode, if: :should_geocode?

  # Associations
  belongs_to :city
  has_one :state, through: :city
  has_one :country, through: :state
  has_many :reviews, dependent: :destroy
  has_many :company_service_areas, dependent: :destroy
  has_many :service_areas, through: :company_service_areas, source: :city
  has_many :company_services, dependent: :destroy
  has_many :service_categories, through: :company_services
  has_many :gallery_images, dependent: :destroy
  has_many :certifications, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :city_id }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true
  validates :average_rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }

  # Callbacks
  before_validation :generate_slug

  # Methods
  def url_path
    "/sewer-line-repair/#{country.slug}/#{state.slug}/#{city.slug}/#{slug}"
  end

  def update_rating!
    if reviews.any?
      self.average_rating = reviews.average(:rating).round(2)
      self.total_reviews = reviews.count
    else
      self.average_rating = 0
      self.total_reviews = 0
    end
    save
  end

  def full_address
    [street_address, city&.name, state&.name, zip_code].compact.join(", ")
  end

  private

  def generate_slug
    self.slug = name.parameterize if name.present? && slug.blank?
  end

  def should_geocode?
    (latitude.blank? || longitude.blank?) && street_address.present?
  end
end
