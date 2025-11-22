# Working Hours Feature Implementation

## Overview
Added `working_hours` JSONB field to the `companies` table to store flexible business hours information for each company.

## Database Changes

### Migration
- **File**: `db/migrate/20251122055437_add_working_hours_to_companies.rb`
- **Field**: `working_hours` (JSONB, nullable)
- **Location**: `companies` table

```ruby
add_column :companies, :working_hours, :jsonb
```

## Model Updates

### Company Model
- **File**: `app/models/company.rb`
- Added attribute definition for JSONB field with default empty hash

```ruby
attribute :working_hours, :jsonb, default: {}
```

## Serializer Updates

### CompanySerializer
- **File**: `app/serializers/company_serializer.rb`
- Added `working_hours` to attributes list

### CompanyDetailSerializer
- **File**: `app/serializers/company_detail_serializer.rb`
- Added `working_hours` to attributes list

## Factory Updates

### Company Factory
- **File**: `spec/factories/companies.rb`
- Added default 24/7 working hours for test data

```ruby
working_hours do
  {
    'Sunday' => 'Open 24 hours',
    'Monday' => 'Open 24 hours',
    'Tuesday' => 'Open 24 hours',
    'Wednesday' => 'Open 24 hours',
    'Thursday' => 'Open 24 hours',
    'Friday' => 'Open 24 hours',
    'Saturday' => 'Open 24 hours'
  }
end
```

## Seed Data Updates

### Rake Task: seed_companies
- **File**: `lib/tasks/seed_companies.rake`
- Added `generate_working_hours` helper method
- Generates random working hours for each company with realistic patterns

### Working Hours Patterns (Weighted Distribution)

1. **24/7 Operation** (30% chance)
   - All days: "Open 24 hours"

2. **Standard Business Hours** (20% chance)
   - Monday-Friday: 8:00 AM - 5:00 PM
   - Saturday-Sunday: Closed

3. **Extended Hours** (25% chance)
   - Monday-Friday: 7:00 AM - 7:00 PM
   - Saturday: 8:00 AM - 4:00 PM
   - Sunday: Closed

4. **Early Start with Saturday** (15% chance)
   - Monday-Friday: 6:00 AM - 6:00 PM
   - Saturday: 7:00 AM - 3:00 PM
   - Sunday: Closed

5. **Weekend Service** (10% chance)
   - Monday-Friday: 7:00 AM - 6:00 PM
   - Saturday: 8:00 AM - 5:00 PM
   - Sunday: 9:00 AM - 5:00 PM

## API Response Format

### Example Response

```json
{
  "data": {
    "id": "1",
    "type": "company",
    "attributes": {
      "name": "Precision Wastewater Repair",
      "working_hours": {
        "Sunday": "9:00 AM - 5:00 PM",
        "Monday": "7:00 AM - 6:00 PM",
        "Tuesday": "7:00 AM - 6:00 PM",
        "Wednesday": "7:00 AM - 6:00 PM",
        "Thursday": "7:00 AM - 6:00 PM",
        "Friday": "7:00 AM - 6:00 PM",
        "Saturday": "8:00 AM - 5:00 PM"
      }
    }
  }
}
```

## RSpec Updates

### Companies Spec
- **File**: `spec/requests/api/v1/companies_spec.rb`
- Updated schema to include `working_hours` object with all weekday properties

## Usage Examples

### Accessing Working Hours in Rails

```ruby
# Get a company
company = Company.first

# Access working hours
company.working_hours
# => {"Sunday"=>"Closed", "Monday"=>"8:00 AM - 5:00 PM", ...}

# Check if open on specific day
company.working_hours['Monday']
# => "8:00 AM - 5:00 PM"

# Set working hours
company.working_hours = {
  'Sunday' => 'Closed',
  'Monday' => '9:00 AM - 5:00 PM',
  # ... etc
}
company.save
```

### API Endpoints

All company endpoints now return working_hours:

- `GET /api/v1/companies/search` - Search companies (includes working_hours)
- `GET /api/v1/companies/:id` - Company details (includes working_hours)

## Database Reset with New Data

To recreate the database with working hours:

```bash
# Stop any running Rails servers
pkill -9 -f puma

# Drop, create, and migrate database
bin/rails db:drop db:create db:migrate

# Seed US states and cities
bin/rails db:seed:us_data

# Seed 2000 companies with working hours
bin/rails db:seed:companies
```

## Data Distribution

After seeding:
- **Total Companies**: 2000
- **Cities**: 1152
- **Average per City**: ~1.74 companies
- **Working Hours Variety**: 5 different patterns with realistic distribution

## Benefits

1. **Flexibility**: JSONB allows for any format of working hours
2. **Queryable**: Can use PostgreSQL JSONB operators to query by working hours
3. **No Schema Changes**: Adding new day formats or patterns doesn't require migrations
4. **API Ready**: Automatically serialized in JSON API responses
5. **Realistic Data**: Seed data includes variety of business hour patterns

## Future Enhancements

Potential improvements:
- Add validation for working hours format
- Add helper methods to check if currently open
- Add timezone support
- Add special holiday hours
- Add search/filter by working hours (e.g., "open now", "open weekends")

## Related Files

- Migration: `db/migrate/20251122055437_add_working_hours_to_companies.rb`
- Model: `app/models/company.rb`
- Serializers: `app/serializers/company_serializer.rb`, `app/serializers/company_detail_serializer.rb`
- Factory: `spec/factories/companies.rb`
- Seed Task: `lib/tasks/seed_companies.rake`
- Spec: `spec/requests/api/v1/companies_spec.rb`

---

**Implementation Date**: November 22, 2025
**Status**: ✅ Complete

