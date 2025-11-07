class CompanySerializer
  include JSONAPI::Serializer

  set_type :company
  set_id :id

  attributes :name, :slug, :phone, :email, :website, :street_address, :zip_code,
             :latitude, :longitude, :description, :average_rating, :total_reviews,
             :verified_professional, :licensed, :insured, :background_checked,
             :certified_partner, :service_guarantee, :service_level, :specialty,
             :created_at, :updated_at

  attribute :url_path, &:url_path

  attribute :full_address, &:full_address

  belongs_to :city
  has_one :state, through: :city
  has_one :country, through: :state
  has_many :reviews
  has_many :service_categories
  has_many :gallery_images
  has_many :certifications
  has_many :service_areas, serializer: :city

  # Add distance if available
  attribute :distance_mi, if: proc { |company| company.respond_to?(:distance) } do |company|
    company.distance&.round(2)
  end

  attribute :distance_km, if: proc { |company| company.respond_to?(:distance) } do |company|
    (company.distance * 1.60934).round(2) if company.distance
  end

  link :self do |company|
    "/api/v1/companies/#{company.id}"
  end
end
