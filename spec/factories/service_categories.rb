FactoryBot.define do
  factory :service_category do
    name { 'Sewer Line Repair' }
    slug { 'sewer-line-repair' }
    description { 'Complete sewer line repair and replacement services' }

    trait :drain_cleaning do
      name { 'Drain Cleaning' }
      slug { 'drain-cleaning' }
      description { 'Professional drain cleaning and unclogging services' }
    end

    trait :camera_inspection do
      name { 'Camera Inspection' }
      slug { 'camera-inspection' }
      description { 'Video camera inspection of sewer and drain lines' }
    end

    trait :trenchless_repair do
      name { 'Trenchless Repair' }
      slug { 'trenchless-repair' }
      description { 'No-dig sewer line repair using trenchless technology' }
    end

    trait :hydro_jetting do
      name { 'Hydro Jetting' }
      slug { 'hydro-jetting' }
      description { 'High-pressure water jetting for thorough pipe cleaning' }
    end
  end
end
