class CompanyDetailSerializer
  include JSONAPI::Serializer

  set_type :company
  set_id :id

  attributes :name, :slug, :phone, :email, :site, :street_address, :postal_code,
             :latitude, :longitude, :average_rating, :total_reviews,
             :verified_professional,
             :working_hours, :about, :subtypes, :logo_url, :booking_appointment_link,
             :borough, :timezone, :created_at, :updated_at

  attribute :url_path, &:url_path
  attribute :full_address, &:full_address

  attribute :service_categories do |company|
    company.service_categories.map do |category|
      {
        id: category.id,
        name: category.name,
        slug: category.slug,
        description: category.description
      }
    end
  end
end
# frozen_string_literal: true
