# frozen_string_literal: true

class ReviewSerializer
  include JSONAPI::Serializer

  set_type :review
  set_id :id

  attributes :reviewer_name, :review_date, :rating, :review_text, :verified, :created_at

  # Relationships
  belongs_to :company

  # Self link
  link :self do |object|
    "/api/v1/reviews/#{object.id}"
  end
end
