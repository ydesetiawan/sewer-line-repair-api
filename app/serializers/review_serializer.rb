class ReviewSerializer
  include JSONAPI::Serializer

  set_type :review
  set_id :id

  attributes :reviewer_name, :rating, :review_text, :review_date,
             :verified, :created_at, :updated_at

  belongs_to :company

  link :self do |review|
    "/api/v1/companies/#{review.company_id}/reviews/#{review.id}"
  end
end
