class Company < ApplicationRecord
  # Geocoding
  geocoded_by :full_address

  # Callbacks
  before_validation :generate_slug
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

  # Store accessor for JSONB fields (optional, for easier attribute access)
  # This allows accessing working_hours as a hash
  attribute :working_hours, :jsonb, default: {}

  # Scopes
  scope :near, lambda { |coordinates, radius_in_miles = 20|
    lat, lng = Geocoder::Calculations.extract_coordinates(coordinates)
    return none unless lat && lng

    earth_radius = 3958.8 # miles

    # Haversine formula for distance calculation
    distance_calc = "(#{earth_radius} * 2 * ASIN(SQRT(
      POWER(SIN((#{lat} - companies.latitude) * PI() / 180 / 2), 2) +
      COS(#{lat} * PI() / 180) * COS(companies.latitude * PI() / 180) *
      POWER(SIN((#{lng} - companies.longitude) * PI() / 180 / 2), 2)
    )))"

    # Use where and order without select to avoid AS keyword issue
    where("#{distance_calc} <= #{radius_in_miles}")
      .order(Arel.sql(distance_calc))
  }

  # Methods
  def url_path
    "/#{country.slug}/#{state.slug}/#{city.slug}/#{slug}"
  end

  def update_rating!
    if reviews.any?
      avg_rating = reviews.average(:rating)
      self.average_rating = avg_rating ? avg_rating.round(2) : 0
      self.total_reviews = reviews.count
    else
      self.average_rating = 0
      self.total_reviews = 0
    end
    save
  end

  def full_address
    [street_address, city&.name, state&.name, zip_code].compact.join(', ')
  end

  private

  def generate_slug
    self.slug = name.parameterize if name.present? && slug.blank?
  end

  def should_geocode?
    (latitude.blank? || longitude.blank?) && street_address.present?
  end
end
