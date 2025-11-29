# Reviews Table Restructure & Company Timezone Addition

## Overview
Completely restructured the `reviews` table to support richer review data from external sources (like Google Maps reviews) and added `timezone` field to companies table.

---

## 1. Reviews Table Restructure

### ❌ Removed Fields
All old fields were removed except `company_id`:
- `reviewer_name` (string)
- `review_date` (date)
- `rating` (integer)
- `review_text` (text) - removed then re-added with same name
- `verified` (boolean)

### ✅ New Fields Added

| Field Name | Type | Default | Description |
|------------|------|---------|-------------|
| `author_title` | string | `nil` | Reviewer's name/title |
| `author_image` | string | `nil` | URL to reviewer's profile image |
| `review_text` | text | `nil` | The review content/body |
| `review_img_urls` | text[] | `[]` | Array of image URLs attached to review |
| `owner_answer` | text | `nil` | Business owner's response to review |
| `owner_answer_timestamp_datetime_utc` | datetime | `nil` | When owner responded (UTC) |
| `review_link` | string | `nil` | Direct link to original review |
| `review_rating` | integer | `nil` | Rating from 1-5 |
| `review_datetime_utc` | datetime | `nil` | When review was posted (UTC) |

### Database Constraints
- **Check Constraint**: `review_rating >= 1 AND review_rating <= 5`
- **Indexes**:
  - `review_rating` - For filtering by rating
  - `review_datetime_utc` - For sorting by date
  - `[company_id, review_datetime_utc]` - Composite index for company reviews sorted by date

### Migration Details
**File**: `db/migrate/20251129072824_restructure_reviews.rb`

```ruby
class RestructureReviews < ActiveRecord::Migration[8.1]
  def change
    # Remove old columns (except company_id)
    remove_column :reviews, :reviewer_name, :string
    remove_column :reviews, :review_date, :date
    remove_column :reviews, :rating, :integer
    remove_column :reviews, :review_text, :text
    remove_column :reviews, :verified, :boolean
    
    # Remove old indexes and constraints
    remove_index :reviews, name: 'index_reviews_on_company_id_and_review_date'
    remove_index :reviews, name: 'index_reviews_on_rating'
    remove_check_constraint :reviews, name: 'rating_range'
    
    # Add new columns
    add_column :reviews, :author_title, :string
    add_column :reviews, :author_image, :string
    add_column :reviews, :review_text, :text
    add_column :reviews, :review_img_urls, :text, array: true, default: []
    add_column :reviews, :owner_answer, :text
    add_column :reviews, :owner_answer_timestamp_datetime_utc, :datetime
    add_column :reviews, :review_link, :string
    add_column :reviews, :review_rating, :integer
    add_column :reviews, :review_datetime_utc, :datetime
    
    # Add new indexes
    add_index :reviews, :review_rating
    add_index :reviews, :review_datetime_utc
    add_index :reviews, [:company_id, :review_datetime_utc]
    
    # Add check constraint
    add_check_constraint :reviews, 'review_rating >= 1 AND review_rating <= 5', 
                         name: 'review_rating_range'
  end
end
```

---

## 2. Company Timezone Field

### New Field
| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `timezone` | string | `'UTC'` | Company's timezone (e.g., 'America/New_York') |

### Migration Details
**File**: `db/migrate/20251129072829_add_timezone_to_companies.rb`

```ruby
class AddTimezoneToCompanies < ActiveRecord::Migration[8.1]
  def change
    add_column :companies, :timezone, :string, default: 'UTC'
  end
end
```

---

## Code Changes

### 1. Review Model (`app/models/review.rb`)

**Updated Validations:**
```ruby
validates :review_rating, presence: true, 
          inclusion: { in: 1..5 }, 
          numericality: { only_integer: true }
validates :review_link, 
          format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, 
          allow_blank: true
validates :author_image, 
          format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, 
          allow_blank: true
```

**New Scopes:**
```ruby
scope :recent, -> { order(review_datetime_utc: :desc) }
scope :top_rated, -> { where('review_rating >= ?', 4).order(review_rating: :desc) }
scope :with_owner_answer, -> { where.not(owner_answer: nil) }
```

### 2. Company Model (`app/models/company.rb`)

**Updated Method:**
```ruby
def update_rating!
  if reviews.any?
    avg_rating = reviews.average(:review_rating) # Changed from :rating
    self.average_rating = avg_rating ? avg_rating.round(2) : 0
    self.total_reviews = reviews.count
  else
    self.average_rating = 0
    self.total_reviews = 0
  end
  save
end
```

### 3. Review Serializer (`app/serializers/review_serializer.rb`)

**New Attributes:**
```ruby
attributes :author_title, :author_image, :review_text, :review_img_urls,
           :owner_answer, :owner_answer_timestamp_datetime_utc, :review_link,
           :review_rating, :review_datetime_utc, :created_at, :updated_at
```

### 4. Company Serializers

**Added to both `CompanySerializer` and `CompanyDetailSerializer`:**
```ruby
attributes ..., :timezone, ...
```

**Updated in `CompanyDetailSerializer` reviews attribute:**
```ruby
attribute :reviews do |company|
  company.reviews.map do |review|
    {
      id: review.id,
      author_title: review.author_title,
      author_image: review.author_image,
      review_text: review.review_text,
      review_img_urls: review.review_img_urls,
      owner_answer: review.owner_answer,
      owner_answer_timestamp_datetime_utc: review.owner_answer_timestamp_datetime_utc,
      review_link: review.review_link,
      review_rating: review.review_rating,
      review_datetime_utc: review.review_datetime_utc,
      created_at: review.created_at,
      updated_at: review.updated_at
    }
  end
end
```

### 5. Review Factory (`spec/factories/reviews.rb`)

**Completely Restructured:**
```ruby
FactoryBot.define do
  factory :review do
    company
    sequence(:author_title) { |n| "Customer #{n}" }
    sequence(:author_image) { |n| "https://cdn.example.com/avatars/user#{n}.jpg" }
    review_text { 'Excellent service! Very professional and thorough.' }
    review_img_urls { ['https://cdn.example.com/reviews/img1.jpg'] }
    owner_answer { nil }
    owner_answer_timestamp_datetime_utc { nil }
    sequence(:review_link) { |n| "https://maps.google.com/review#{n}" }
    review_rating { 5 }
    review_datetime_utc { Time.current }

    trait :with_owner_answer do
      owner_answer { 'Thank you for your review!' }
      owner_answer_timestamp_datetime_utc { 1.day.ago }
    end

    trait :negative do
      review_rating { 2 }
      review_text { 'Service could be improved.' }
    end

    trait :positive do
      review_rating { 5 }
      review_text { 'Outstanding work!' }
    end
  end
end
```

### 6. Company Factory (`spec/factories/companies.rb`)

**Added:**
```ruby
timezone { 'America/New_York' }
```

### 7. Seeds File (`db/seeds.rb`)

**Updated review creation:**
```ruby
companies.each do |company|
  rand(5..15).times do |i|
    review_datetime = rand(1..365).days.ago
    has_owner_answer = [true, false, false].sample
    
    company.reviews.create!(
      author_title: ['John Smith', 'Sarah Johnson', ...].sample,
      author_image: "https://cdn.example.com/avatars/user#{rand(1..100)}.jpg",
      review_datetime_utc: review_datetime,
      review_rating: rand(3..5),
      review_text: ['Excellent service!', ...].sample,
      review_img_urls: rand(0..3).times.map { |j| 
        "https://cdn.example.com/reviews/img#{rand(1..1000)}.jpg" 
      },
      review_link: "https://maps.google.com/reviews/#{company.id}/#{i}",
      owner_answer: has_owner_answer ? 'Thank you!' : nil,
      owner_answer_timestamp_datetime_utc: has_owner_answer ? 
        (review_datetime + rand(1..7).days) : nil
    )
  end
  company.update_rating!
end
```

---

## Usage Examples

### Creating a Review
```ruby
review = Review.create!(
  company: company,
  author_title: 'John Doe',
  author_image: 'https://cdn.example.com/avatars/john.jpg',
  review_text: 'Excellent service! Very professional.',
  review_rating: 5,
  review_datetime_utc: Time.current,
  review_link: 'https://maps.google.com/review/12345',
  review_img_urls: [
    'https://cdn.example.com/review-img1.jpg',
    'https://cdn.example.com/review-img2.jpg'
  ]
)
```

### Adding Owner Response
```ruby
review.update!(
  owner_answer: 'Thank you for your kind words!',
  owner_answer_timestamp_datetime_utc: Time.current
)
```

### Querying Reviews
```ruby
# Get recent reviews
company.reviews.recent.limit(10)

# Get top-rated reviews
company.reviews.top_rated

# Get reviews with owner responses
company.reviews.with_owner_answer

# Get reviews by rating
company.reviews.where(review_rating: 5)
```

### Setting Company Timezone
```ruby
company.update!(timezone: 'America/Los_Angeles')
company.update!(timezone: 'Europe/London')
company.update!(timezone: 'Asia/Tokyo')
```

---

## API Response Example

### Review in API Response
```json
{
  "id": 1,
  "author_title": "John Doe",
  "author_image": "https://cdn.example.com/avatars/john.jpg",
  "review_text": "Excellent service! Very professional and thorough.",
  "review_img_urls": [
    "https://cdn.example.com/review-img1.jpg",
    "https://cdn.example.com/review-img2.jpg"
  ],
  "owner_answer": "Thank you for your kind words!",
  "owner_answer_timestamp_datetime_utc": "2025-11-28T10:30:00.000Z",
  "review_link": "https://maps.google.com/review/12345",
  "review_rating": 5,
  "review_datetime_utc": "2025-11-27T14:20:00.000Z",
  "created_at": "2025-11-27T14:20:00.000Z",
  "updated_at": "2025-11-28T10:30:00.000Z"
}
```

### Company with Timezone
```json
{
  "data": {
    "id": "CMPabc123xyz",
    "type": "company",
    "attributes": {
      "name": "Elite Plumbing Services",
      "timezone": "America/New_York",
      "average_rating": 4.8,
      "total_reviews": 127
    }
  }
}
```

---

## Benefits

### Review Structure Benefits
1. **Rich Data**: Support for images, links, and owner responses
2. **External Integration**: Perfect for importing Google/Yelp reviews
3. **Better UX**: Display reviewer avatars and review images
4. **Engagement**: Track owner responses to reviews
5. **Timestamps**: Proper UTC datetime tracking

### Timezone Benefits
1. **Accurate Scheduling**: Display working hours in company's local time
2. **Better UX**: Show appointment times correctly
3. **Multi-timezone Support**: Support companies across different timezones

---

## Database Schema

### Reviews Table (Final)
```sql
CREATE TABLE reviews (
  id bigserial PRIMARY KEY,
  company_id varchar(255) NOT NULL,
  author_title varchar(255),
  author_image varchar(255),
  review_text text,
  review_img_urls text[] DEFAULT '{}',
  owner_answer text,
  owner_answer_timestamp_datetime_utc timestamp,
  review_link varchar(255),
  review_rating integer,
  review_datetime_utc timestamp,
  created_at timestamp NOT NULL,
  updated_at timestamp NOT NULL,
  
  CONSTRAINT review_rating_range CHECK (review_rating >= 1 AND review_rating <= 5),
  CONSTRAINT fk_rails_... FOREIGN KEY (company_id) REFERENCES companies(id)
);

CREATE INDEX index_reviews_on_company_id ON reviews(company_id);
CREATE INDEX index_reviews_on_review_rating ON reviews(review_rating);
CREATE INDEX index_reviews_on_review_datetime_utc ON reviews(review_datetime_utc);
CREATE INDEX index_reviews_on_company_id_and_review_datetime_utc 
  ON reviews(company_id, review_datetime_utc);
```

### Companies Table (timezone field)
```sql
ALTER TABLE companies ADD COLUMN timezone varchar(255) DEFAULT 'UTC';
```

---

## Migration Commands

```bash
# Drop and recreate databases
rails db:drop db:create db:migrate
RAILS_ENV=test rails db:drop db:create db:migrate

# Run seeds
rails db:seed

# Run tests
bundle exec rspec
```

---

## Files Modified Summary

| File | Change Type |
|------|-------------|
| `db/migrate/20251129072824_restructure_reviews.rb` | New migration |
| `db/migrate/20251129072829_add_timezone_to_companies.rb` | New migration |
| `app/models/review.rb` | Complete restructure |
| `app/models/company.rb` | Updated rating method |
| `app/serializers/review_serializer.rb` | Updated attributes |
| `app/serializers/company_serializer.rb` | Added timezone |
| `app/serializers/company_detail_serializer.rb` | Added timezone & updated reviews |
| `spec/factories/reviews.rb` | Complete restructure |
| `spec/factories/companies.rb` | Added timezone |
| `db/seeds.rb` | Updated review creation |

**Total**: 10 files (2 new migrations, 8 modified)

---

## Important Notes

1. **Breaking Change**: This is a complete restructure of the reviews table
2. **Data Loss**: All existing review data will be lost (migration drops columns)
3. **Fresh Database**: Requires `rails db:drop db:create db:migrate`
4. **External Sources**: Designed for importing reviews from Google/Yelp/etc
5. **UTC Timestamps**: All datetime fields use UTC for consistency
6. **Array Field**: `review_img_urls` uses PostgreSQL array type

---

**Status**: ✅ Complete  
**Date**: November 29, 2025  
**Database**: Fresh migration required  
**Breaking Changes**: Yes - reviews table completely restructured

