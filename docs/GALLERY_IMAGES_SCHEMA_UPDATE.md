# Gallery Images Serializer Updated to Match Schema

## ✅ Successfully Updated Gallery Images

All gallery image-related files have been updated to match the migration schema.

---

## Migration Schema (Current)

**File**: `db/migrate/20251106005335_create_gallery_images.rb`

```ruby
create_table :gallery_images do |t|
  t.string :company_id, limit: 255, null: false, index: true
  t.string :image_url, null: false
  t.string :thumbnail_url
  t.string :video_url
  t.datetime :image_datetime_utc

  t.timestamps
end
```

### Fields:
- `company_id` (string, 255) - Foreign key to companies
- `image_url` (string) - **Required** - URL to full-size image
- `thumbnail_url` (string) - Optional - URL to thumbnail image
- `video_url` (string) - Optional - URL to video
- `image_datetime_utc` (datetime) - When image/video was taken
- `created_at`, `updated_at` - Timestamps

---

## Changes Made

### 1. ✅ GalleryImageSerializer Updated

**File**: `app/serializers/gallery_image_serializer.rb`

**Changed From**:
```ruby
attributes :title, :description, :position, :image_type, :created_at, :updated_at
```

**Changed To**:
```ruby
attributes :image_url, :thumbnail_url, :video_url, :image_datetime_utc, :created_at, :updated_at
```

### 2. ✅ GalleryImage Model Updated

**File**: `app/models/gallery_image.rb`

**Added**:
- Validation for `image_url` (required, URL format)
- Validation for `thumbnail_url` (optional, URL format)
- Validation for `video_url` (optional, URL format)
- Scopes: `images`, `videos`, `recent`

**New Model**:
```ruby
class GalleryImage < ApplicationRecord
  belongs_to :company

  validates :image_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }
  validates :thumbnail_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }
  validates :video_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }

  scope :images, -> { where.not(image_url: nil) }
  scope :videos, -> { where.not(video_url: nil) }
  scope :recent, -> { order(image_datetime_utc: :desc) }
end
```

### 3. ✅ Factory Updated

**File**: `spec/factories/gallery_images.rb`

**Changed From**:
```ruby
title { 'Sewer Line Repair Work' }
description { 'Professional sewer line repair work completed' }
position { 0 }
image_type { 'before' }
```

**Changed To**:
```ruby
sequence(:image_url) { |n| "https://cdn.example.com/images/gallery/image#{n}.jpg" }
sequence(:thumbnail_url) { |n| "https://cdn.example.com/images/gallery/thumb#{n}.jpg" }
image_datetime_utc { Time.current }

trait :with_video do
  sequence(:video_url) { |n| "https://cdn.example.com/videos/gallery/video#{n}.mp4" }
end
```

---

## API Response Example

### Before
```json
{
  "data": {
    "id": "1",
    "type": "gallery_image",
    "attributes": {
      "title": "Sewer Line Repair Work",
      "description": "Professional sewer line repair work completed",
      "position": 0,
      "image_type": "before",
      "created_at": "2025-11-29T10:00:00Z",
      "updated_at": "2025-11-29T10:00:00Z"
    }
  }
}
```

### After
```json
{
  "data": {
    "id": "1",
    "type": "gallery_image",
    "attributes": {
      "image_url": "https://cdn.example.com/images/gallery/image1.jpg",
      "thumbnail_url": "https://cdn.example.com/images/gallery/thumb1.jpg",
      "video_url": null,
      "image_datetime_utc": "2025-11-29T10:00:00Z",
      "created_at": "2025-11-29T10:00:00Z",
      "updated_at": "2025-11-29T10:00:00Z"
    }
  }
}
```

---

## Usage Examples

### Creating Gallery Images

```ruby
# Image only
gallery_image = GalleryImage.create!(
  company: company,
  image_url: 'https://cdn.example.com/work-photo.jpg',
  thumbnail_url: 'https://cdn.example.com/work-photo-thumb.jpg',
  image_datetime_utc: Time.current
)

# With video
gallery_image = GalleryImage.create!(
  company: company,
  image_url: 'https://cdn.example.com/video-thumbnail.jpg',
  video_url: 'https://cdn.example.com/work-video.mp4',
  image_datetime_utc: 2.days.ago
)
```

### Querying

```ruby
# Get all images for a company
company.gallery_images.images

# Get all videos for a company
company.gallery_images.videos

# Get recent gallery items
company.gallery_images.recent.limit(10)
```

### Using Factory

```ruby
# Create image
image = create(:gallery_image, company: company)

# Create with video
video = create(:gallery_image, :with_video, company: company)

# Create old image
old_image = create(:gallery_image, :old, company: company)
```

---

## Key Differences from Previous Schema

### Removed Fields
- ❌ `title` - Text title
- ❌ `description` - Text description
- ❌ `position` - Display order
- ❌ `image_type` - Category (before/after/work/team/equipment)

### Added Fields
- ✅ `image_url` - **Required** - Direct image URL
- ✅ `thumbnail_url` - Optional thumbnail URL
- ✅ `video_url` - Optional video URL
- ✅ `image_datetime_utc` - Timestamp when media was captured

---

## Design Philosophy

### External Storage Approach
- Gallery images store **URLs only** (no file uploads)
- Actual images/videos stored on CDN or cloud storage
- Supports external services: AWS S3, Cloudinary, Imgix, etc.

### Benefits
1. **Scalability**: CDN handles image serving
2. **Performance**: Optimized image delivery
3. **Flexibility**: Easy to change storage providers
4. **Simplicity**: No server-side file management

---

## Migration Path

### To Use This Schema

1. **Drop and recreate database**:
```bash
rails db:drop db:create db:migrate
```

2. **For existing data**:
   - Write a migration to transform old fields to new URLs
   - Upload existing images to CDN
   - Update records with new URLs

---

## Validation Rules

### Image URL (Required)
- Must be present
- Must be valid HTTP/HTTPS URL
- Example: `https://cdn.example.com/image.jpg`

### Thumbnail URL (Optional)
- Must be valid HTTP/HTTPS URL if provided
- Example: `https://cdn.example.com/thumb.jpg`

### Video URL (Optional)
- Must be valid HTTP/HTTPS URL if provided
- Example: `https://cdn.example.com/video.mp4`

### Image DateTime UTC (Optional)
- Stores when the photo/video was taken
- Uses UTC timezone
- Useful for sorting and displaying chronologically

---

## Scopes Available

### `images`
Returns gallery items that have an image_url (excludes video-only items)

### `videos`
Returns gallery items that have a video_url

### `recent`
Orders gallery items by image_datetime_utc descending (newest first)

---

## Files Modified Summary

| File | Change |
|------|--------|
| `app/serializers/gallery_image_serializer.rb` | Updated attributes |
| `app/models/gallery_image.rb` | Added validations & scopes |
| `spec/factories/gallery_images.rb` | Updated factory fields |

**Total**: 3 files updated

---

## Next Steps

1. ✅ Run migration to update database
2. ✅ Test creating gallery images with new fields
3. ✅ Update any API documentation
4. ✅ Implement image upload to CDN (if needed)
5. ✅ Update frontend to use new field names

---

**Status**: ✅ **COMPLETE**  
**Schema**: Matches migration exactly  
**Validations**: URL format checking  
**Factory**: Updated with realistic data  
**Ready**: Yes - serializer aligned with database schema

