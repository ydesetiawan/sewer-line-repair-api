FactoryBot.define do
  factory :review do
    company
    reviewer_name { 'John Smith' }
    review_date { Time.zone.today }
    rating { 5 }
    review_text { 'Excellent service! Very professional and thorough.' }
    verified { true }

    trait :unverified do
      verified { false }
    end

    trait :negative do
      rating { 2 }
      review_text { 'Service could be improved. Response time was slow.' }
    end

    trait :positive do
      rating { 5 }
      review_text { 'Outstanding work! Highly recommend their services.' }
    end

    trait :recent do
      review_date { 1.day.ago }
    end

    trait :old do
      review_date { 6.months.ago }
    end

    trait :with_customer_name do
      sequence(:reviewer_name) { |n| ['John Smith', 'Sarah Johnson', 'Michael Brown', 'Emily Davis'][n % 4] }
    end
  end
end
