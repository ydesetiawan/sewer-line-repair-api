class CompanyDetailSerializer
  include JSONAPI::Serializer

  set_type :company
  set_id :id

  attributes :name, :slug, :phone, :email, :website, :street_address, :zip_code,
             :latitude, :longitude, :description, :average_rating, :total_reviews,
             :verified_professional, :licensed, :insured, :background_checked,
             :certified_partner, :service_guarantee, :service_level, :specialty,
             :working_hours, :created_at, :updated_at

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

  attribute :reviews do |company|
    company.reviews.map do |review|
      {
        id: review.id,
        rating: review.rating,
        title: review.title,
        body: review.body,
        reviewer_name: review.reviewer_name,
        created_at: review.created_at,
        updated_at: review.updated_at
      }
    end
  end
end
# frozen_string_literal: true
