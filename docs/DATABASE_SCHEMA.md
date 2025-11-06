# Sewer Repair Directory - Database Schema Documentation

## Overview

This document describes the complete database schema for the Sewer Repair Directory application, including all tables, relationships, indexes, and constraints.

## Schema Version

- Rails: 8.1.1
- Ruby: 3.4.7
- Database: PostgreSQL
- Created: November 6, 2025

---

## Table Structure

### 1. Countries

Stores country information for the location hierarchy.

**Columns:**
- `id` (bigint, primary key)
- `name` (string, required) - Country name
- `code` (string(2), required, unique) - ISO 2-letter country code (e.g., "US")
- `slug` (string, required, unique) - URL-friendly slug
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes:**
- `index_countries_on_code` (unique)
- `index_countries_on_slug` (unique)

**Relationships:**
- has_many: states, cities (through states)

---

### 2. States

Stores state/province information.

**Columns:**
- `id` (bigint, primary key)
- `country_id` (bigint, required, foreign key)
- `name` (string, required) - State name
- `code` (string(10), required) - State code (e.g., "FL", "CA")
- `slug` (string, required) - URL-friendly slug
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes:**
- `index_states_on_country_id`
- `index_states_on_country_id_and_slug` (unique composite)
- `index_states_on_country_id_and_code`

**Relationships:**
- belongs_to: country
- has_many: cities, companies (through cities)

---

### 3. Cities

Stores city information with optional coordinates.

**Columns:**
- `id` (bigint, primary key)
- `state_id` (bigint, required, foreign key)
- `name` (string, required) - City name
- `slug` (string, required) - URL-friendly slug
- `latitude` (decimal(10,6)) - Geographic latitude
- `longitude` (decimal(10,6)) - Geographic longitude
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes:**
- `index_cities_on_state_id`
- `index_cities_on_state_id_and_slug` (unique composite)
- `index_cities_on_latitude_and_longitude`

**Relationships:**
- belongs_to: state
- has_one: country (through state)
- has_many: companies, company_service_areas

---

### 4. Service Categories

Defines types of services companies can offer.

**Columns:**
- `id` (bigint, primary key)
- `name` (string, required) - Category name
- `slug` (string, required, unique) - URL-friendly slug
- `description` (text) - Category description
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes:**
- `index_service_categories_on_slug` (unique)

**Relationships:**
- has_many: company_services, companies (through company_services)

**Sample Data:**
- Sewer Line Repair
- Drain Cleaning
- Camera Inspection
- Trenchless Repair
- Hydro Jetting

---

### 5. Companies

Main entity storing company/business information.

**Columns:**
- `id` (bigint, primary key)
- `city_id` (bigint, required, foreign key) - Primary location
- `name` (string, required) - Company name
- `slug` (string, required) - URL-friendly slug
- `phone` (string) - Contact phone
- `email` (string) - Contact email
- `website` (string) - Company website URL
- `street_address` (string) - Street address
- `zip_code` (string) - Postal/ZIP code
- `latitude` (decimal(10,6)) - Exact location latitude
- `longitude` (decimal(10,6)) - Exact location longitude
- `specialty` (string) - Business specialty
- `service_level` (string) - Service tier level
- `description` (text) - Company description
- `average_rating` (decimal(3,2), default: 0) - Calculated average rating
- `total_reviews` (integer, default: 0) - Total review count
- `verified_professional` (boolean, default: false)
- `certified_partner` (boolean, default: false)
- `licensed` (boolean, default: false)
- `insured` (boolean, default: false)
- `background_checked` (boolean, default: false)
- `service_guarantee` (boolean, default: false)
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes:**
- `index_companies_on_city_id`
- `index_companies_on_city_id_and_slug` (unique composite)
- `index_companies_on_average_rating`
- `index_companies_on_name`

**Relationships:**
- belongs_to: city
- has_one: state (through city), country (through state)
- has_many: reviews, company_service_areas, service_areas (through company_service_areas), company_services, service_categories (through company_services), gallery_images, certifications

**Methods:**
- `url_path` - Returns full URL path: "/sewer-line-repair/country/state/city/company-slug"
- `update_rating!` - Recalculates average_rating and total_reviews from reviews

---

### 6. Reviews

Customer reviews for companies.

**Columns:**
- `id` (bigint, primary key)
- `company_id` (bigint, required, foreign key)
- `reviewer_name` (string, required) - Name of reviewer
- `review_date` (date, required) - Date of review
- `rating` (integer, required) - Star rating (1-5)
- `review_text` (text) - Review content
- `verified` (boolean, default: false) - Verified purchase/service
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes:**
- `index_reviews_on_company_id`
- `index_reviews_on_company_id_and_review_date`
- `index_reviews_on_rating`

**Constraints:**
- Check constraint: `rating >= 1 AND rating <= 5`

**Relationships:**
- belongs_to: company

**Callbacks:**
- after_save: calls `company.update_rating!`
- after_destroy: calls `company.update_rating!`

**Scopes:**
- `verified` - Only verified reviews
- `recent` - Ordered by review_date desc

---

### 7. Company Service Areas

Junction table linking companies to additional service cities.

**Columns:**
- `id` (bigint, primary key)
- `company_id` (bigint, required, foreign key)
- `city_id` (bigint, required, foreign key)
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes:**
- `index_company_service_areas_on_company_id`
- `index_company_service_areas_on_city_id`
- `index_company_service_areas_on_company_id_and_city_id` (unique composite)

**Relationships:**
- belongs_to: company, city

**Validations:**
- Prevents adding company's primary city to service areas

---

### 8. Company Services

Junction table linking companies to service categories.

**Columns:**
- `id` (bigint, primary key)
- `company_id` (bigint, required, foreign key)
- `service_category_id` (bigint, required, foreign key)
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes:**
- `index_company_services_on_company_id`
- `index_company_services_on_service_category_id`
- `index_company_services_unique` (unique composite on company_id and service_category_id)

**Relationships:**
- belongs_to: company, service_category

---

### 9. Gallery Images

Photos and images for company portfolios.

**Columns:**
- `id` (bigint, primary key)
- `company_id` (bigint, required, foreign key)
- `title` (string) - Image title
- `description` (text) - Image description
- `image_url` (string, required) - Full image URL
- `thumbnail_url` (string) - Thumbnail image URL
- `position` (integer, default: 0, required) - Display order
- `image_type` (string) - Type: before, after, work, team, equipment
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes:**
- `index_gallery_images_on_company_id`
- `index_gallery_images_on_company_id_and_position`
- `index_gallery_images_on_image_type`

**Relationships:**
- belongs_to: company

**Scopes:**
- default_scope: ordered by position asc
- `by_type(type)` - Filter by image_type

**Callbacks:**
- before_create: auto-sets position if not provided

---

### 10. Certifications

Professional certifications and licenses for companies.

**Columns:**
- `id` (bigint, primary key)
- `company_id` (bigint, required, foreign key)
- `certification_name` (string, required) - Name of certification
- `issuing_organization` (string) - Organization that issued cert
- `issue_date` (date) - Date issued
- `expiry_date` (date) - Expiration date (optional)
- `certificate_number` (string) - Certificate/license number
- `certificate_url` (string) - URL to certificate document
- `created_at` (datetime)
- `updated_at` (datetime)

**Indexes:**
- `index_certifications_on_company_id`
- `index_certifications_on_expiry_date`

**Relationships:**
- belongs_to: company

**Scopes:**
- `active` - Where expiry_date is null or > today
- `expired` - Where expiry_date < today
- `expiring_soon` - Where expiry_date is between today and 30 days from now

**Methods:**
- `expired?` - Returns true if certification is expired
- `expires_soon?` - Returns true if expires within 30 days

---

## Entity Relationship Diagram

```
Country (1) ──< (many) State (1) ──< (many) City
                                              │
                                              ├──< (many) Company
                                              │              │
                                              │              ├──< (many) Review
                                              │              ├──< (many) GalleryImage
                                              │              ├──< (many) Certification
                                              │              ├──< (many) CompanyService ──> ServiceCategory
                                              │              └──< (many) CompanyServiceArea
                                              │
                                              └──< (many) CompanyServiceArea ──> Company
```

---

## Data Flow Examples

### 1. Finding a Company
```ruby
# Full hierarchy access
company = Company.first
company.city.name           # => "Orlando"
company.state.name          # => "Florida"
company.country.name        # => "United States"
company.url_path            # => "/sewer-line-repair/united-states/florida/orlando/company-slug"
```

### 2. Company Services
```ruby
company = Company.first
company.service_categories.pluck(:name)  # => ["Sewer Line Repair", "Drain Cleaning"]
company.service_areas.pluck(:name)       # => ["Miami", "Tampa"]
```

### 3. Reviews and Ratings
```ruby
# Creating a review automatically updates company rating
review = company.reviews.create!(
  reviewer_name: "John Doe",
  rating: 5,
  review_date: Date.today,
  review_text: "Great service!"
)
# company.average_rating and company.total_reviews are automatically updated
```

### 4. Certifications
```ruby
# Find companies with active certifications
Company.joins(:certifications).merge(Certification.active).distinct

# Check expiring certifications
Certification.expiring_soon.includes(:company)
```

---

## Performance Considerations

### Indexed Fields
All foreign keys are indexed for fast lookups.
Slug fields are indexed for URL routing.
Composite indexes on location hierarchy for efficient filtering.

### Caching Opportunities
- `average_rating` and `total_reviews` are cached fields updated via callbacks
- Consider caching `url_path` if accessed frequently
- Gallery images default scope ordered by position

### Query Optimization
- Use `includes()` for N+1 query prevention
- Use `pluck()` for simple data retrieval
- Index on `average_rating` for sorting companies

---

## Seed Data Summary

- 1 Country (United States)
- 3 States (Florida, Texas, California)
- 15 Cities (5 per state)
- 5 Service Categories
- 9-10 Companies (1 per city)
- 5-15 Reviews per company
- 3-7 Gallery images per company
- 1-3 Certifications per company

---

## Migration Commands

```bash
# Run migrations
bin/rails db:migrate

# Rollback last migration
bin/rails db:rollback

# Reset database (drop, create, migrate, seed)
bin/rails db:reset

# Seed data
bin/rails db:seed

# View schema
bin/rails db:schema:dump
```

---

## Testing Models

```bash
# Run test script
bin/rails runner lib/tasks/test_models.rb

# Rails console
bin/rails console

# Example queries
Country.first.cities.count
Company.first.url_path
Company.first.update_rating!
Certification.active
Review.verified.recent
```

---

## Active Storage Integration

As of November 6, 2025, the GalleryImage model has been updated to use **Active Storage** for file uploads.

### Additional Tables (Active Storage)

**active_storage_blobs:**
- Stores file metadata (filename, content_type, byte_size, checksum, etc.)

**active_storage_attachments:**
- Polymorphic join table linking files to any model
- Links GalleryImage records to their image files

**active_storage_variant_records:**
- Caches processed image variants (thumbnails, resized versions)

### GalleryImage Changes

**Removed columns:**
- `image_url` - No longer storing URLs as strings
- `thumbnail_url` - No longer storing URLs as strings

**New functionality:**
- `has_one_attached :image` - Main image file attachment
- `has_one_attached :thumbnail` - Optional separate thumbnail
- Auto-generated variants for different sizes
- File validation (type, size)

See `ACTIVE_STORAGE_MIGRATION.md` for complete details.

---

**Last Updated:** November 6, 2025  
**Active Storage:** ✅ Enabled

