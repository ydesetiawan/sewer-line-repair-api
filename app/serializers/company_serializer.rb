# frozen_string_literal: true

class CompanySerializer
  include JSONAPI::Serializer

  set_type :company
  set_id :id

  attributes :name, :slug, :phone, :email, :website,
             :street_address, :zip_code, :latitude, :longitude,
             :specialty, :service_level, :description,
             :average_rating, :total_reviews,
             :verified_professional, :certified_partner,
             :licensed, :insured, :background_checked,
             :service_guarantee, :created_at, :updated_at

  # Conditional distance attributes (only when searching by location)
  attribute :distance_miles, if: proc { |record, params|
    params && params[:include_distance] && record.respond_to?(:distance_miles)
  }

  attribute :distance_kilometers, if: proc { |record, params|
    params && params[:include_distance] && record.respond_to?(:distance_kilometers)
  }

  # Relationships with explicit serializers
  belongs_to :city, serializer: :city
  has_many :reviews, serializer: :review
  has_many :service_categories, serializer: :service_category
  has_many :gallery_images, serializer: :gallery_image
  has_many :certifications, serializer: :certification
  has_many :service_areas, serializer: :city

  # Self link
  link :self do |object|
    "/api/v1/companies/#{object.id}"
  end
end

