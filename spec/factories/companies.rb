FactoryBot.define do
  factory :company do
    city
    sequence(:name) { |n| "Elite Sewer Solutions #{n}" }
    sequence(:phone) { |n| "(555) 555-#{format('%04d', n)}" }
    sequence(:email) { |n| "contact#{n}@elitesewerco.com" }
    sequence(:website) { |n| "https://www.elitesewerco#{n}.com" }
    street_address { '1234 Main St' }
    sequence(:zip_code) { |n| format('%05d', 10_000 + n) }
    latitude { 28.5383 }
    longitude { -81.3792 }
    description { 'Professional sewer and drain services with over 15 years of experience. Licensed, insured, and available 24/7 for emergency services.' }
    average_rating { 4.5 }
    total_reviews { 0 }
    verified_professional { true }
    licensed { true }
    insured { true }
    background_checked { true }
    certified_partner { false }
    service_guarantee { true }
    service_level { 'premium' }
    specialty { 'Sewer Line Repair' }

    trait :unverified do
      verified_professional { false }
      licensed { false }
      insured { false }
      background_checked { false }
    end

    trait :certified do
      certified_partner { true }
    end

    trait :high_rated do
      average_rating { 5.0 }
      total_reviews { 50 }
    end

    trait :low_rated do
      average_rating { 2.5 }
      total_reviews { 10 }
    end

    trait :with_reviews do
      after(:create) do |company|
        create_list(:review, 5, company: company)
        company.update_rating!
      end
    end

    trait :with_service_categories do
      after(:create) do |company|
        create(:company_service, company: company, service_category: create(:service_category))
        create(:company_service, company: company, service_category: create(:service_category, :drain_cleaning))
      end
    end
  end
end
