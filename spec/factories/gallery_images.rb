FactoryBot.define do
  factory :gallery_image do
    company
    sequence(:image_url) { |n| "https://cdn.example.com/images/gallery/image#{n}.jpg" }
    sequence(:thumbnail_url) { |n| "https://cdn.example.com/images/gallery/thumb#{n}.jpg" }
    image_datetime_utc { Time.current }

    trait :with_video do
      sequence(:video_url) { |n| "https://cdn.example.com/videos/gallery/video#{n}.mp4" }
    end

    trait :recent do
      image_datetime_utc { 1.day.ago }
    end

    trait :old do
      image_datetime_utc { 6.months.ago }
    end
  end
end
