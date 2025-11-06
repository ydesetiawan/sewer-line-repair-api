# Active Storage Integration - Gallery Images

## Overview

The `GalleryImage` model has been updated to use **Active Storage** for file uploads, following Rails best practices.

## What Changed

### Database Structure

**Removed columns:**
- `image_url` (string)
- `thumbnail_url` (string)

**Added tables (Active Storage):**
- `active_storage_blobs` - Stores file metadata
- `active_storage_attachments` - Polymorphic join table
- `active_storage_variant_records` - Stores image variants

**Kept columns:**
- `id`, `company_id`, `title`, `description`, `image_type`, `position`, `timestamps`

### Active Storage Tables

```ruby
# active_storage_blobs
- id
- key (unique filename)
- filename
- content_type
- metadata (JSON)
- service_name
- byte_size
- checksum
- created_at

# active_storage_attachments (polymorphic)
- id
- name (e.g., "image", "thumbnail")
- record_type ("GalleryImage")
- record_id (gallery_image_id)
- blob_id (foreign key to blobs)
- created_at

# active_storage_variant_records
- id
- blob_id
- variation_digest
- created_at
```

---

## Model Configuration

### Attachments

```ruby
class GalleryImage < ApplicationRecord
  # Two attachments per gallery image
  has_one_attached :image        # Main full-size image
  has_one_attached :thumbnail    # Optional separate thumbnail
end
```

### Validations

```ruby
# Presence
validates :image, presence: true

# File type validation
validate :acceptable_image_format
# Accepts: JPEG, PNG, GIF, WebP

# File size validation
validate :acceptable_image_size
# Maximum: 10 MB
```

### Image Variants (Auto-generated)

```ruby
# Thumbnail variant (200x150)
gallery_image.thumbnail_variant

# Large variant (800x600)
gallery_image.large_variant

# Usage in views/JSON:
url_for(gallery_image.thumbnail_variant)
```

---

## API Usage

### Creating Gallery Image with Upload

```ruby
# In controller
def create
  @gallery_image = @company.gallery_images.build(gallery_image_params)
  
  if @gallery_image.save
    render json: @gallery_image, status: :created
  else
    render json: @gallery_image.errors, status: :unprocessable_entity
  end
end

private

def gallery_image_params
  params.require(:gallery_image).permit(
    :title,
    :description,
    :image_type,
    :position,
    :image,       # File upload
    :thumbnail    # Optional thumbnail
  )
end
```

### JSON Response with Image URLs

```ruby
# In serializer or jbuilder
{
  id: gallery_image.id,
  title: gallery_image.title,
  description: gallery_image.description,
  image_type: gallery_image.image_type,
  position: gallery_image.position,
  image_url: gallery_image.image_url,           # Full URL
  thumbnail_url: gallery_image.thumbnail_url,   # Thumbnail URL
  large_url: url_for(gallery_image.large_variant),
  created_at: gallery_image.created_at
}
```

---

## File Upload Examples

### Via Form (multipart/form-data)

```bash
curl -X POST http://localhost:3000/api/v1/companies/1/gallery_images \
  -F "gallery_image[title]=Before Repair" \
  -F "gallery_image[image_type]=before" \
  -F "gallery_image[image]=@/path/to/image.jpg"
```

### Via Base64 (JSON API)

```ruby
# Controller accepts base64 encoded images
def create
  if params[:gallery_image][:image_base64].present?
    decoded_image = Base64.decode64(params[:gallery_image][:image_base64])
    @gallery_image.image.attach(
      io: StringIO.new(decoded_image),
      filename: params[:gallery_image][:filename] || 'image.jpg',
      content_type: params[:gallery_image][:content_type] || 'image/jpeg'
    )
  end
  
  # ... rest of create logic
end
```

### Direct Upload (JavaScript)

```javascript
// Using Active Storage Direct Upload
// Add gem 'activestorage-validator' for better validation

const input = document.querySelector('input[type=file]')
const file = input.files[0]

const upload = new ActiveStorage.DirectUpload(
  file,
  '/rails/active_storage/direct_uploads'
)

upload.create((error, blob) => {
  if (error) {
    console.error(error)
  } else {
    // Submit signed_blob_id to your API
    const signed_id = blob.signed_id
    
    fetch('/api/v1/companies/1/gallery_images', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        gallery_image: {
          title: 'Project Photo',
          image: signed_id
        }
      })
    })
  }
})
```

---

## Storage Configuration

### Local Storage (Development/Test)

```yaml
# config/storage.yml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>

test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>
```

Files stored in: `storage/` directory

### Cloud Storage (Production)

**Amazon S3:**
```yaml
amazon:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
  region: us-east-1
  bucket: sewer-repair-gallery
```

**Azure Blob Storage:**
```yaml
microsoft:
  service: AzureStorage
  storage_account_name: <%= Rails.application.credentials.dig(:azure, :storage_account_name) %>
  storage_access_key: <%= Rails.application.credentials.dig(:azure, :storage_access_key) %>
  container: gallery-images
```

**Google Cloud Storage:**
```yaml
google:
  service: GCS
  project: your-project-id
  credentials: <%= Rails.application.credentials.dig(:gcs, :keyfile) %>
  bucket: sewer-repair-images
```

Set environment variable:
```ruby
# config/environments/production.rb
config.active_storage.service = :amazon  # or :microsoft, :google
```

---

## Image Processing

### Install Image Processing Gem

```ruby
# Gemfile
gem 'image_processing', '~> 1.2'

# Then run:
bundle install
```

### Available Transformations

```ruby
# Resize to fit
gallery_image.image.variant(resize_to_fit: [800, 600])

# Resize to fill (crop to exact size)
gallery_image.image.variant(resize_to_fill: [800, 600])

# Resize to limit (proportional, max dimensions)
gallery_image.image.variant(resize_to_limit: [800, 600])

# Custom transformations
gallery_image.image.variant(
  resize_to_limit: [800, 600],
  format: :jpg,
  saver: { quality: 80 }
)
```

---

## Helper Methods

### In GalleryImage Model

```ruby
# Get image URL
gallery_image.image_url
# => "/rails/active_storage/blobs/..."

# Get thumbnail URL (if separate thumbnail attached)
gallery_image.thumbnail_url
# => "/rails/active_storage/blobs/..."

# Get variant
gallery_image.thumbnail_variant
# => <ActiveStorage::Variant>

# Check if attached
gallery_image.image.attached?  # => true/false

# Get filename
gallery_image.image.filename  # => "photo.jpg"

# Get content type
gallery_image.image.content_type  # => "image/jpeg"

# Get file size
gallery_image.image.byte_size  # => 524288 (bytes)
```

---

## Querying Images

```ruby
# Find images with attachments
GalleryImage.joins(:image_attachment)

# Eager load images (avoid N+1)
@gallery_images = @company.gallery_images.with_attached_image

# Multiple attachments
@gallery_images = @company.gallery_images
  .with_attached_image
  .with_attached_thumbnail
```

---

## Background Jobs

Active Storage uses background jobs for:
- Image analysis (dimensions, etc.)
- Virus scanning (if configured)
- Variant generation

Configure job adapter:
```ruby
# config/environments/production.rb
config.active_job.queue_adapter = :sidekiq  # or :delayed_job, :resque
```

---

## Security Best Practices

### 1. Validate File Types
Already implemented in model:
```ruby
validate :acceptable_image_format
# Only allows: JPEG, PNG, GIF, WebP
```

### 2. Validate File Size
Already implemented:
```ruby
validate :acceptable_image_size
# Maximum: 10 MB
```

### 3. Content Security
Add to `config/initializers/content_security_policy.rb`:
```ruby
Rails.application.config.content_security_policy do |policy|
  policy.connect_src :self, :https, "http://localhost:3035", "ws://localhost:3035" if Rails.env.development?
  
  # Allow images from Active Storage
  if Rails.env.development?
    policy.img_src :self, :https, :data, :blob
  end
end
```

### 4. Virus Scanning (Production)
```ruby
# Gemfile
gem 'active_storage_validations'

# Model
validates :image, 
  content_type: ['image/png', 'image/jpg', 'image/jpeg'],
  size: { less_than: 10.megabytes }
```

---

## Testing with RSpec

```ruby
# spec/models/gallery_image_spec.rb
require 'rails_helper'

RSpec.describe GalleryImage, type: :model do
  describe 'validations' do
    it 'requires an image attachment' do
      gallery_image = build(:gallery_image)
      gallery_image.image = nil
      expect(gallery_image).not_to be_valid
      expect(gallery_image.errors[:image]).to include("can't be blank")
    end
    
    it 'accepts valid image formats' do
      gallery_image = build(:gallery_image)
      image = fixture_file_upload('test_image.jpg', 'image/jpeg')
      gallery_image.image.attach(image)
      expect(gallery_image).to be_valid
    end
    
    it 'rejects invalid image formats' do
      gallery_image = build(:gallery_image)
      pdf = fixture_file_upload('test.pdf', 'application/pdf')
      gallery_image.image.attach(pdf)
      expect(gallery_image).not_to be_valid
    end
  end
  
  describe 'variants' do
    it 'generates thumbnail variant' do
      gallery_image = create(:gallery_image, :with_image)
      expect(gallery_image.thumbnail_variant).to be_a(ActiveStorage::Variant)
    end
  end
end
```

### Factory Example

```ruby
# spec/factories/gallery_images.rb
FactoryBot.define do
  factory :gallery_image do
    company
    title { "Sample Image" }
    description { "A test image" }
    image_type { "work" }
    position { 0 }
    
    trait :with_image do
      after(:build) do |gallery_image|
        gallery_image.image.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg')),
          filename: 'test_image.jpg',
          content_type: 'image/jpeg'
        )
      end
    end
  end
end
```

---

## Migration Summary

### What Was Migrated

1. ✅ Added Active Storage tables (blobs, attachments, variants)
2. ✅ Removed `image_url` and `thumbnail_url` columns
3. ✅ Updated model to use `has_one_attached :image`
4. ✅ Added file type and size validations
5. ✅ Added helper methods for URLs and variants
6. ✅ Configured storage services

### Migration Commands Used

```bash
# Generate Active Storage tables
bin/rails active_storage:install

# Remove old columns
bin/rails generate migration RemoveImageUrlsFromGalleryImages

# Run migrations
bin/rails db:migrate
```

---

## Next Steps

1. **Add image processing gem** for variants:
   ```bash
   bundle add image_processing
   ```

2. **Configure cloud storage** for production:
   - Set up S3/Azure/GCS bucket
   - Add credentials: `bin/rails credentials:edit`
   - Update `config.active_storage.service` in production

3. **Add direct upload** for better UX:
   - Enable CORS on storage bucket
   - Use JavaScript DirectUpload

4. **Optimize performance**:
   - Use CDN for serving images
   - Enable caching headers
   - Lazy load images in frontend

---

**Last Updated:** November 6, 2025  
**Rails Version:** 8.1.1  
**Active Storage:** Enabled ✅

