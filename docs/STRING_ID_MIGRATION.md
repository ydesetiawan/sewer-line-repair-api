# Company String ID Migration

## Overview

Successfully migrated the `companies` table from using integer primary keys to string primary keys. This allows for flexible ID assignment, supporting both auto-generated IDs and manually assigned IDs (such as Google Place IDs).

## Changes Made

### Database Schema Changes

#### 1. Companies Table
- **Primary Key**: Changed from `bigint` to `string(255)`
- **Auto-generation**: Generates IDs in format `CMP{20 alphanumeric characters}` (e.g., `CMPnhi1jGU6SKKKv8SGiWSt`)
- **Manual Assignment**: Supports manual ID input (e.g., `ChIJ36aZWc4TK4cRbgJ-FyroXmo`)

#### 2. Related Tables (Foreign Keys)
All tables with `company_id` foreign keys were updated to use `string(255)`:
- `reviews.company_id`
- `company_service_areas.company_id`
- `company_services.company_id`
- `gallery_images.company_id`
- `certifications.company_id`

### Migration Files Modified

1. **20251106005331_create_companies.rb**
   - Changed `create_table :companies` to `create_table :companies, id: false`
   - Added explicit string primary key: `t.string :id, limit: 255, primary_key: true, null: false`

2. **20251106005332_create_reviews.rb**
   - Changed `t.references :company` to `t.string :company_id, limit: 255, null: false, index: true`
   - Added explicit foreign key constraint

3. **20251106005333_create_company_service_areas.rb**
   - Changed `t.references :company` to `t.string :company_id, limit: 255, null: false, index: true`
   - Added explicit foreign key constraint

4. **20251106005334_create_company_services.rb**
   - Changed `t.references :company` to `t.string :company_id, limit: 255, null: false, index: true`
   - Added explicit foreign key constraint

5. **20251106005335_create_gallery_images.rb**
   - Changed `t.references :company` to `t.string :company_id, limit: 255, null: false, index: true`
   - Added explicit foreign key constraint

6. **20251106005336_create_certifications.rb**
   - Changed `t.references :company` to `t.string :company_id, limit: 255, null: false, index: true`
   - Added explicit foreign key constraint

### Model Changes

**app/models/company.rb**
```ruby
class Company < ApplicationRecord
  # Callbacks
  before_create :generate_string_id
  # ...existing code...
  
  private
  
  def generate_string_id
    # Only generate ID if not manually provided
    return if id.present?
    
    # Generate a unique string ID similar to Google Place ID format
    loop do
      self.id = "CMP#{SecureRandom.alphanumeric(20)}"
      break unless Company.exists?(id: self.id)
    end
  end
end
```

## Usage

### Auto-Generated ID
```ruby
company = Company.create!(
  city: city,
  name: 'Auto ID Company',
  slug: 'auto-id-company'
)
# company.id => "CMPnhi1jGU6SKKKv8SGiWSt"
```

### Manual ID Assignment
```ruby
company = Company.create!(
  id: 'ChIJ36aZWc4TK4cRbgJ-FyroXmo',  # Google Place ID
  city: city,
  name: 'Manual ID Company',
  slug: 'manual-id-company'
)
# company.id => "ChIJ36aZWc4TK4cRbgJ-FyroXmo"
```

### Working with Relationships
```ruby
# Create a review for a company with string ID
review = company.reviews.create!(
  reviewer_name: 'John Doe',
  review_date: Date.today,
  rating: 5,
  review_text: 'Great service!'
)
# review.company_id => "ChIJ36aZWc4TK4cRbgJ-FyroXmo" (string)
```

## Benefits

1. **Flexible ID Assignment**: Supports both auto-generated and manually assigned IDs
2. **External ID Integration**: Can use external identifiers (Google Place IDs, etc.) directly as primary keys
3. **Human-Readable**: String IDs are more readable than UUIDs
4. **URL-Safe**: Generated IDs use alphanumeric characters only
5. **Collision-Free**: Auto-generated IDs have 20 characters (62^20 possible combinations)

## Migration Process

1. **Backup**: Always backup your database before migration
2. **Fresh Start**: Dropped and recreated database (no data migration needed)
3. **Run Migrations**: `rails db:drop db:create db:migrate`
4. **Seed Data**: `rails db:seed`
5. **Verify**: Run tests to ensure everything works: `bundle exec rspec`

## Testing

All existing tests pass without modification:
```bash
bundle exec rspec spec/models/company_spec.rb
# 13 examples, 0 failures
```

## API Impact

- **Serializers**: No changes needed - IDs are serialized as strings
- **Controllers**: No changes needed - string IDs work with standard CRUD operations
- **Routes**: Company IDs in URLs are now strings (e.g., `/api/v1/companies/CMPnhi1jGU6SKKKv8SGiWSt`)

## Database Performance

- **Indexes**: All foreign key indexes maintained
- **Query Performance**: String primary keys have minimal performance impact for varchar(255)
- **Storage**: Slightly more storage than bigint (255 bytes max vs 8 bytes), but actual IDs use 23 characters (23 bytes)

## Rollback

This migration is **irreversible** as it requires a fresh database creation. To rollback:
1. Revert migration files to use `t.references :company`
2. Drop and recreate database
3. Restore from backup

## Future Considerations

- Consider adding validation for ID format if needed
- Document ID format standards for manual assignment
- Consider adding ID prefix constants for different entity types

## Related Files

- Models: `app/models/company.rb`
- Migrations: `db/migrate/20251106005331_create_companies.rb` and related
- Tests: `spec/models/company_spec.rb`
- Factories: `spec/factories/companies.rb`
- Serializers: `app/serializers/company_serializer.rb`

