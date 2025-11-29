FactoryBot.define do
  factory :gallery_image do
    company
    title { 'Sewer Line Repair Work' }
    description { 'Professional sewer line repair work completed' }
    position { 0 }
    image_type { 'before' }


    trait :ordered do
      sequence(:position)
    end

    trait :after_image do
      image_type { 'after' }
    end

    trait :work_image do
      image_type { 'work' }
    end

    trait :team_image do
      image_type { 'team' }
    end

    trait :equipment_image do
      image_type { 'equipment' }
    end
  end
end
