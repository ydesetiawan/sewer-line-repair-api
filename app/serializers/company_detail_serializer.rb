class CompanyDetailSerializer
  include JSONAPI::Serializer

  set_type :company
  set_id :id

  attributes :name, :slug, :phone, :email, :website, :street_address, :zip_code,
             :latitude, :longitude, :description, :average_rating, :total_reviews,
             :verified_professional, :licensed, :insured, :background_checked,
             :certified_partner, :service_guarantee, :service_level, :specialty,
             :created_at, :updated_at

  attribute :url_path, &:url_path

  attribute :city do |company|
    {
      id: company.city.id,
      name: company.city.name,
      slug: company.city.slug
    }
  end

  attribute :full_address, &:full_address
end
# frozen_string_literal: true

