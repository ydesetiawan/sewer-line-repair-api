class ReviewSerializer
  include JSONAPI::Serializer

  set_type :review
  set_id :id

  attributes :author_title, :author_image, :review_text, :review_img_urls,
             :owner_answer, :owner_answer_timestamp_datetime_utc, :review_link,
             :review_rating, :review_datetime_utc, :created_at, :updated_at

  belongs_to :company

  link :self do |review|
    "/api/v1/companies/#{review.company_id}/reviews/#{review.id}"
  end
end
