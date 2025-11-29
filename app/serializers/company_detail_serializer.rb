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

  attribute :reviews do |company|
    company.reviews.map do |review|
      {
        id: review.id,
        author_title: review.author_title,
        author_image: review.author_image,
        review_text: review.review_text,
        review_img_urls: review.review_img_urls,
        owner_answer: review.owner_answer,
        owner_answer_timestamp_datetime_utc: review.owner_answer_timestamp_datetime_utc,
        review_link: review.review_link,
        review_rating: review.review_rating,
        review_datetime_utc: review.review_datetime_utc,
        created_at: review.created_at,
        updated_at: review.updated_at
      }
    end
  end
end
# frozen_string_literal: true
