# Geocoding Implementation Summary

## Date: November 7, 2025

## Overview
Successfully implemented and tested the `near` method for both City and Company models to support proximity-based searches using the Geocoder gem with custom PostgreSQL-compatible scopes.

## Changes Made

### 1. Database Migration
- **File**: `db/migrate/20251107094022_add_lat_long_index_to_companies.rb`
- Added composite index on `latitude` and `longitude` columns for the `companies` table
- This improves query performance for proximity searches

### 2. City Model (`app/models/city.rb`)
- Added `reverse_geocoded_by :latitude, :longitude` for geocoding support
- Implemented custom `near` scope using Haversine formula
- Scope accepts coordinates `[lat, lng]` and radius in miles
- Returns results ordered by distance
- Avoids PostgreSQL reserved word conflicts by not using "AS distance"

### 3. Company Model (`app/models/company.rb`)
- Added `geocoded_by :full_address` for automatic address geocoding
- Implemented `after_validation :geocode` callback with conditional `should_geocode?`
- Implemented custom `near` scope (same as City model)
- Added `full_address` method that combines street_address, city, state, zip_code
- Added `should_geocode?` method to only geocode when coordinates are missing

### 4. Test Files
- **City Specs** (`spec/models/city_spec.rb`):
  - Tests for `.near` scope with different radii
  - Tests for distance ordering
  - Tests for empty results
  - Tests for validations and slug generation
  
- **Company Specs** (`spec/models/company_spec.rb`):
  - Tests for `.near` scope with multiple companies
  - Tests for geocoding callbacks with proper mocking
  - Tests for `full_address` method
  - Tests for validations

### 5. Configuration
- **File**: `config/initializers/geocoder.rb`
- Updated to use `distances: :spherical` for better accuracy
- Set `units: :mi` for miles-based calculations
- Added `distance_column: :calculated_distance` to avoid keyword conflicts

### 6. Documentation
- **File**: `docs/GEOCODING_GUIDE.md`
- Comprehensive guide on using the geocoding functionality
- Usage examples for both models
- Testing patterns with RSpec
- Production recommendations
- Troubleshooting guide

## Technical Details

### Custom Near Scope Implementation
```ruby
scope :near, ->(coordinates, radius_in_miles = 20) {
  lat, lng = Geocoder::Calculations.extract_coordinates(coordinates)
  return none unless lat && lng
  
  earth_radius = 3958.8 # miles
  
  # Haversine formula for distance calculation
  distance_calc = "(#{earth_radius} * 2 * ASIN(SQRT(
    POWER(SIN((#{lat} - tablename.latitude) * PI() / 180 / 2), 2) +
    COS(#{lat} * PI() / 180) * COS(tablename.latitude * PI() / 180) *
    POWER(SIN((#{lng} - tablename.longitude) * PI() / 180 / 2), 2)
  )))"
  
  where("#{distance_calc} <= #{radius_in_miles}")
    .order(Arel.sql(distance_calc))
}
```

### Why Custom Scopes?
The default Geocoder gem's `near` method generated SQL with "AS distance" which caused syntax errors in PostgreSQL due to reserved word conflicts. Our custom implementation:
- Uses the same Haversine formula for accuracy
- Avoids the "AS distance" syntax
- Returns results ordered by distance
- Is fully compatible with ActiveRecord

## Test Results
All 20 tests passing:
- ✅ 8 City model tests (geocoding + validations)
- ✅ 12 Company model tests (geocoding + callbacks + validations + full_address)

## Usage Examples

### Finding Nearby Cities
```ruby
# Find cities within 50 miles of San Francisco
nearby_cities = City.near([37.7749, -122.4194], 50)
nearest_city = nearby_cities.first
```

### Finding Nearby Companies
```ruby
# Find companies within 25 miles
nearby_companies = Company.near([37.7749, -122.4194], 25)
company_count = nearby_companies.count
```

### Controller Usage
```ruby
def geocode
  coordinates = Geocoder.coordinates(params[:address])
  if coordinates
    lat, lng = coordinates
    nearest_city = City.near([lat, lng], 50).first
    nearby_companies_count = Company.near([lat, lng], 25).count
    # ... render response
  end
end
```

## Benefits
1. **Performance**: Indexed columns for fast proximity searches
2. **Accuracy**: Haversine formula for spherical distance calculations
3. **Reliability**: No external API calls for proximity searches (only for geocoding addresses)
4. **Testability**: Easy to test with RSpec without external dependencies
5. **Compatibility**: Works with all PostgreSQL versions without reserved word conflicts

## Future Improvements
1. Add caching for geocoding results to reduce API calls
2. Consider PostGIS extension for more advanced spatial queries
3. Add distance to results (currently calculated but not returned in model)
4. Implement reverse geocoding for companies (lat/lng to address)
5. Add rate limiting for external geocoding API calls

## Files Modified
- `app/models/city.rb`
- `app/models/company.rb`
- `config/initializers/geocoder.rb`
- `spec/models/city_spec.rb` (created)
- `spec/models/company_spec.rb` (created)
- `docs/GEOCODING_GUIDE.md` (created/updated)
- `db/migrate/20251107094022_add_lat_long_index_to_companies.rb` (created)

## Dependencies
- geocoder (1.8.6) - Already installed
- No additional gems required

## Verified Working
- ✅ Database indexes created successfully
- ✅ City.near scope works correctly
- ✅ Company.near scope works correctly
- ✅ Geocoding callbacks work with proper stubbing
- ✅ All RSpec tests passing
- ✅ No PostgreSQL syntax errors
- ✅ Distance ordering working correctly

