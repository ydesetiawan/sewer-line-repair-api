# Reviews & Company Updates - Quick Summary

## ✅ Changes Completed

### 1. Reviews Table - Complete Restructure

**❌ Removed (old fields):**
- reviewer_name
- review_date  
- rating
- verified

**✅ Added (new fields):**
- `author_title` - Reviewer name
- `author_image` - Reviewer avatar URL
- `review_text` - Review content
- `review_img_urls` - Array of image URLs
- `owner_answer` - Business owner response
- `owner_answer_timestamp_datetime_utc` - When owner responded
- `review_link` - Link to original review
- `review_rating` - Rating 1-5 (with constraint)
- `review_datetime_utc` - When review was posted

### 2. Companies Table - New Field

**✅ Added:**
- `timezone` - Company timezone (default: 'UTC')

---

## Database Changes

### Migrations Created
1. `20251129072824_restructure_reviews.rb` - Reviews table restructure
2. `20251129072829_add_timezone_to_companies.rb` - Add timezone to companies

### Indexes Added
- `review_rating` - For filtering by rating
- `review_datetime_utc` - For sorting by date  
- `[company_id, review_datetime_utc]` - Composite index

### Constraints
- Check constraint: `review_rating >= 1 AND review_rating <= 5`

---

## Code Updates

### Models
- ✅ `app/models/review.rb` - New validations & scopes
- ✅ `app/models/company.rb` - Updated `update_rating!` method

### Serializers
- ✅ `app/serializers/review_serializer.rb` - New attributes
- ✅ `app/serializers/company_serializer.rb` - Added timezone
- ✅ `app/serializers/company_detail_serializer.rb` - Added timezone & updated reviews

### Factories
- ✅ `spec/factories/reviews.rb` - Complete restructure
- ✅ `spec/factories/companies.rb` - Added timezone

### Seeds
- ✅ `db/seeds.rb` - Updated review creation logic

---

## Quick Usage

### Create Review
```ruby
Review.create!(
  company: company,
  author_title: 'John Doe',
  author_image: 'https://example.com/avatar.jpg',
  review_text: 'Excellent service!',
  review_rating: 5,
  review_datetime_utc: Time.current,
  review_link: 'https://maps.google.com/review/123',
  review_img_urls: ['https://example.com/img1.jpg']
)
```

### Set Company Timezone
```ruby
company.update!(timezone: 'America/New_York')
```

---

## Migration Steps

```bash
# Drop and recreate database
rails db:drop db:create db:migrate

# For test database
RAILS_ENV=test rails db:drop db:create db:migrate

# Seed data
rails db:seed
```

---

## Key Points

⚠️ **Breaking Change** - Complete reviews table restructure  
⚠️ **Data Loss** - Existing review data will be deleted  
✅ **Fresh Start** - Designed for external review imports (Google/Yelp)  
✅ **UTC Timestamps** - All datetime fields use UTC  
✅ **Rich Data** - Support for images, links, owner responses  

---

**Status**: ✅ Complete  
**Files Modified**: 10 (2 new, 8 updated)  
**Documentation**: `REVIEWS_RESTRUCTURE.md` (detailed guide)

