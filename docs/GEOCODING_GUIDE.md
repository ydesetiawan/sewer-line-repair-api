# Geocoding Support in Models

This document explains how the `near` method is implemented in the City and Company models to support proximity-based searches.

## Overview

Both `City` and `Company` models use the [Geocoder gem](https://github.com/alexreisner/geocoder) combined with custom scopes to provide location-based functionality.

## City Model

The City model uses `reverse_geocoded_by` combined with a custom `near` scope:

```ruby
class City < ApplicationRecord
  # Geocoding
  reverse_geocoded_by :latitude, :longitude
  
  # Custom scope for proximity searches
  scope :near, ->(coordinates, radius_in_miles = 20) {
    lat, lng = Geocoder::Calculations.extract_coordinates(coordinates)
    return none unless lat && lng
    
    earth_radius = 3958.8 # miles
    
    # Haversine formula for distance calculation
    distance_calc = "(#{earth_radius} * 2 * ASIN(SQRT(
      POWER(SIN((#{lat} - cities.latitude) * PI() / 180 / 2), 2) +
      COS(#{lat} * PI() / 180) * COS(cities.latitude * PI() / 180) *
      POWER(SIN((#{lng} - cities.longitude) * PI() / 180 / 2), 2)
    )))"
    
    where("#{distance_calc} <= #{radius_in_miles}")
      .order(Arel.sql(distance_calc))
  }
end
```

### Database Schema

```ruby
create_table "cities" do |t|
  t.decimal "latitude", precision: 10, scale: 6
  t.decimal "longitude", precision: 10, scale: 6
  t.index ["latitude", "longitude"], name: "index_cities_on_latitude_and_longitude"
end
```

## Company Model

The Company model uses `geocoded_by` to automatically geocode addresses and a custom `near` scope:

```ruby
class Company < ApplicationRecord
  # Geocoding
  geocoded_by :full_address
  
  # Callbacks
  after_validation :geocode, if: :should_geocode?
  
  # Custom scope for proximity searches
  scope :near, ->(coordinates, radius_in_miles = 20) {
    lat, lng = Geocoder::Calculations.extract_coordinates(coordinates)
    return none unless lat && lng
    
    earth_radius = 3958.8 # miles
    
    # Haversine formula for distance calculation
    distance_calc = "(#{earth_radius} * 2 * ASIN(SQRT(
      POWER(SIN((#{lat} - companies.latitude) * PI() / 180 / 2), 2) +
      COS(#{lat} * PI() / 180) * COS(companies.latitude * PI() / 180) *
      POWER(SIN((#{lng} - companies.longitude) * PI() / 180 / 2), 2)
    )))"
    
    where("#{distance_calc} <= #{radius_in_miles}")
      .order(Arel.sql(distance_calc))
  }
  
  def full_address
    [street_address, city&.name, state&.name, zip_code].compact.join(', ')
  end
  
  def should_geocode?
    (latitude.blank? || longitude.blank?) && street_address.present?
  end
end
```

### Database Schema

```ruby
create_table "companies" do |t|
  t.decimal "latitude", precision: 10, scale: 6
  t.decimal "longitude", precision: 10, scale: 6
  t.string "street_address"
  t.string "zip_code"
  t.index ["latitude", "longitude"], name: "index_companies_on_latitude_and_longitude"
end
```

## Usage Examples

### Finding Nearby Cities

```ruby
# Find cities within 50 miles of coordinates
nearby_cities = City.near([37.7749, -122.4194], 50)

# Get the nearest city
nearest_city = City.near([37.7749, -122.4194], 50).first

# Count cities in radius
city_count = City.near([37.7749, -122.4194], 50).count
```

### Finding Nearby Companies

```ruby
# Find companies within 25 miles
nearby_companies = Company.near([37.7749, -122.4194], 25)

# Count companies in radius
company_count = Company.near([37.7749, -122.4194], 25).count

# Get first 10 nearest companies
top_companies = Company.near([37.7749, -122.4194], 50).limit(10)
```

### Using Geocoding in Controllers

```ruby
class Api::V1::LocationsController < ApplicationController
  def geocode
    address = params[:address]
    
    # Geocode the address
    coordinates = Geocoder.coordinates(address)
    
    if coordinates
      lat, lng = coordinates
      
      # Find nearest city within 50 miles
      nearest_city = City.near([lat, lng], 50).first
      
      # Count companies within 25 miles
      nearby_companies_count = Company.near([lat, lng], 25).count
      
      render json: {
        data: {
          type: 'location',
          attributes: {
            address: address,
            latitude: lat,
            longitude: lng,
            nearest_city: nearest_city&.name,
            nearest_state: nearest_city&.state&.name,
            nearby_companies_count: nearby_companies_count
          }
        }
      }
    else
      render json: { error: 'Address not found' }, status: :not_found
    end
  end
end
```

## Testing with RSpec

When testing geocoding functionality, stub the Geocoder methods to avoid external API calls:

```ruby
RSpec.describe 'Locations API', type: :request do
  describe 'POST /api/v1/locations/geocode' do
    let(:address) { '1600 Amphitheatre Parkway, Mountain View, CA' }
    let(:coordinates) { [37.4224764, -122.0842499] }
    let(:state) { create(:state, name: 'California') }
    let(:city) { create(:city, name: 'Mountain View', state: state, latitude: 37.4224764, longitude: -122.0842499) }
    
    before do
      # Stub Geocoder
      allow(Geocoder).to receive(:coordinates).with(address).and_return(coordinates)
      
      # Stub City.near - no need to stub since it uses database
      # Just create test data
      city
    end
    
    it 'returns geocoded location data' do
      post '/api/v1/locations/geocode', params: { address: address }
      
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      
      expect(json.dig('data', 'attributes', 'latitude')).to eq(37.4224764)
      expect(json.dig('data', 'attributes', 'longitude')).to eq(-122.0842499)
      expect(json.dig('data', 'attributes', 'nearest_city')).to eq('Mountain View')
    end
  end
end
```

### Testing the Near Scope

```ruby
RSpec.describe City, type: :model do
  describe '.near' do
    let(:state) { create(:state) }
    let!(:city1) { create(:city, state: state, latitude: 37.7749, longitude: -122.4194) }
    let!(:city2) { create(:city, state: state, latitude: 37.8044, longitude: -122.2712) }
    
    it 'finds cities within specified radius' do
      nearby_cities = City.near([37.7749, -122.4194], 20)
      
      expect(nearby_cities).to include(city1, city2)
    end
    
    it 'orders results by distance' do
      nearby_cities = City.near([37.7749, -122.4194], 50)
      
      expect(nearby_cities.first).to eq(city1) # Closest city
    end
  end
end
```

### Testing Geocoding Callbacks

```ruby
RSpec.describe Company, type: :model do
  describe 'geocoding callbacks' do
    let(:city) { create(:city) }
    
    context 'when company has address but no coordinates' do
      it 'geocodes the address' do
        # Mock geocoding response
        mock_result = double(
          latitude: 37.7749,
          longitude: -122.4194,
          coordinates: [37.7749, -122.4194]
        )
        allow(Geocoder).to receive(:search).and_return([mock_result])
        
        company = create(:company, city: city, street_address: '123 Main St', latitude: nil, longitude: nil)
        
        expect(company.latitude).to eq(37.7749)
        expect(company.longitude).to eq(-122.4194)
      end
    end
  end
end
```

## Configuration

Geocoder configuration is located in `config/initializers/geocoder.rb`:

```ruby
Geocoder.configure(
  timeout: 3,
  lookup: :nominatim,        # Free geocoding service
  units: :mi,                # Use miles for distance
  distances: :spherical,     # Use spherical distance calculation
  distance_column: :calculated_distance
)
```

### Production Recommendations

For production environments, use a commercial geocoding service:

```ruby
# Google Maps
Geocoder.configure(
  lookup: :google,
  api_key: ENV['GOOGLE_MAPS_API_KEY'],
  use_https: true,
  units: :mi
)

# Mapbox
Geocoder.configure(
  lookup: :mapbox,
  api_key: ENV['MAPBOX_API_KEY'],
  use_https: true,
  units: :mi
)
```

## Implementation Notes

### Why Custom Scopes?

We implemented custom `near` scopes instead of using the Geocoder gem's built-in `near` method due to a PostgreSQL reserved word conflict with "distance". Our custom implementation:

1. Uses the Haversine formula for accurate distance calculations
2. Avoids the "AS distance" SQL syntax that causes PostgreSQL errors
3. Returns results ordered by distance
4. Is fully compatible with ActiveRecord query chaining

### Performance Considerations

1. **Database Indexes**: Composite indexes on `(latitude, longitude)` improve query performance significantly
2. **Radius Limits**: Use reasonable radius values (e.g., 50 miles max) to avoid slow queries
3. **Caching**: Consider caching geocoding results to reduce API calls:
   ```ruby
   Rails.cache.fetch("geocode:#{address}", expires_in: 30.days) do
     Geocoder.coordinates(address)
   end
   ```
4. **Rate Limiting**: Be aware of geocoding service rate limits (Nominatim: 1 request/second)

## Troubleshooting

### Near method returns incorrect results

Check that:
- Records have valid latitude/longitude values (not nil)
- Database has proper indexes on latitude and longitude columns
- Coordinates are in decimal degrees format (not DMS)

### Geocoding callback not working

Verify:
- The `should_geocode?` method returns true
- The `full_address` method returns a valid address string
- Geocoder gem is properly configured
- External geocoding service is accessible

### PostgreSQL syntax errors

If you see "syntax error at or near AS", ensure you're using the custom `near` scope implementation provided in this guide, not the default Geocoder near method.

## Related Files

- `app/models/city.rb` - City model with geocoding
- `app/models/company.rb` - Company model with geocoding
- `config/initializers/geocoder.rb` - Geocoder configuration
- `config/initializers/geocoder_postgresql_fix.rb` - PostgreSQL compatibility fixes (if needed)
- `spec/models/city_spec.rb` - City model tests
- `spec/models/company_spec.rb` - Company model tests
- `db/migrate/*_add_lat_long_index_to_companies.rb` - Migration adding indexes

## Running Tests

```bash
# Run all geocoding tests
bundle exec rspec spec/models/city_spec.rb spec/models/company_spec.rb

# Run only near scope tests
bundle exec rspec spec/models/city_spec.rb:9
bundle exec rspec spec/models/company_spec.rb:9
```

