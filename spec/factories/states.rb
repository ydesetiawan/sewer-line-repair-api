FactoryBot.define do
  factory :state do
    country
    name { 'Florida' }
    code { 'FL' }
    slug { 'florida' }

    trait :texas do
      name { 'Texas' }
      code { 'TX' }
      slug { 'texas' }
    end

    trait :california do
      name { 'California' }
      code { 'CA' }
      slug { 'california' }
    end

    trait :new_york do
      name { 'New York' }
      code { 'NY' }
      slug { 'new-york' }
    end
  end
end
