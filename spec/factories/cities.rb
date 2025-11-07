FactoryBot.define do
  factory :city do
    state
    name { 'Orlando' }
    slug { 'orlando' }
    latitude { 28.5383 }
    longitude { -81.3792 }

    trait :miami do
      name { 'Miami' }
      slug { 'miami' }
      latitude { 25.7617 }
      longitude { -80.1918 }
    end

    trait :tampa do
      name { 'Tampa' }
      slug { 'tampa' }
      latitude { 27.9506 }
      longitude { -82.4572 }
    end

    trait :houston do
      name { 'Houston' }
      slug { 'houston' }
      latitude { 29.7604 }
      longitude { -95.3698 }
    end

    trait :dallas do
      name { 'Dallas' }
      slug { 'dallas' }
      latitude { 32.7767 }
      longitude { -96.7970 }
    end

    trait :los_angeles do
      name { 'Los Angeles' }
      slug { 'los-angeles' }
      latitude { 34.0522 }
      longitude { -118.2437 }
    end
  end
end
