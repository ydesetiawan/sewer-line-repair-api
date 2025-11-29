FactoryBot.define do
  factory :review do
    company
    sequence(:author_title) { |n| "Customer #{n}" }
    sequence(:author_image) { |n| "https://cdn.example.com/avatars/user#{n}.jpg" }
    review_text { 'Excellent service! Very professional and thorough.' }
    review_img_urls { ['https://cdn.example.com/reviews/img1.jpg', 'https://cdn.example.com/reviews/img2.jpg'] }
    owner_answer { nil }
    owner_answer_timestamp_datetime_utc { nil }
    sequence(:review_link) { |n| "https://maps.google.com/review#{n}" }
    review_rating { 5 }
    review_datetime_utc { Time.current }

    trait :with_owner_answer do
      owner_answer { 'Thank you for your review! We appreciate your feedback.' }
      owner_answer_timestamp_datetime_utc { 1.day.ago }
    end

    trait :negative do
      review_rating { 2 }
      review_text { 'Service could be improved. Response time was slow.' }
    end

    trait :positive do
      review_rating { 5 }
      review_text { 'Outstanding work! Highly recommend their services.' }
    end

    trait :recent do
      review_datetime_utc { 1.day.ago }
    end

    trait :old do
      review_datetime_utc { 6.months.ago }
    end

    trait :with_customer_name do
      sequence(:reviewer_name) { |n| ['John Smith', 'Sarah Johnson', 'Michael Brown', 'Emily Davis'][n % 4] }
    end
  end
end
