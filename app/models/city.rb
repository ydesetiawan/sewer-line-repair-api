class City < ApplicationRecord
  # Geocoding
  reverse_geocoded_by :latitude, :longitude

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

  # Scopes
  scope :near, lambda { |coordinates, radius = 20, options = {}|
    lat, lng = Geocoder::Calculations.extract_coordinates(coordinates)
    return none unless lat && lng

    # Convert radius to miles if needed
    radius_in_miles = if options[:units] == :km
                        radius * 0.621371 # Convert km to miles
                      else
                        radius
                      end

    earth_radius = 3958.8 # miles

    # Haversine formula for distance calculation
    distance_calc = "(#{earth_radius} * 2 * ASIN(SQRT(
      POWER(SIN((#{lat} - cities.latitude) * PI() / 180 / 2), 2) +
      COS(#{lat} * PI() / 180) * COS(cities.latitude * PI() / 180) *
      POWER(SIN((#{lng} - cities.longitude) * PI() / 180 / 2), 2)
    )))"

    # Use where and order without select to avoid AS keyword issue
    where("#{distance_calc} <= #{radius_in_miles}")
      .order(Arel.sql(distance_calc))
  }

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
