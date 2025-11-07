FactoryBot.define do
  factory :country do
    name { 'United States' }
    code { 'US' }
    slug { 'united-states' }

    trait :canada do
      name { 'Canada' }
      code { 'CA' }
      slug { 'canada' }
    end

    trait :mexico do
      name { 'Mexico' }
      code { 'MX' }
      slug { 'mexico' }
    end
  end
end
