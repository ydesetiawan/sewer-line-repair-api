# Rake Tasks Documentation

## Database Seeding Tasks

### Overview

This document describes the available rake tasks for seeding your database with realistic test data for the Sewer Line Repair API.

**Available Tasks:**
- `db:seed:us_data` - Seed US geographical data (country, states, cities)
- `db:seed:companies` - Seed 2000 companies distributed across all cities

---

## 1. Seed US Data

This rake task creates a realistic geographical database structure for the United States with proper state and city distribution.

#### Usage

```bash
# Run the US data seeding task
bundle exec rake db:seed:us_data
```

#### What it Creates

- **1 Country**: United States (US)
- **50 States**: All US states with proper 2-letter state codes
- **1,000 Cities**: Distributed across states based on realistic population patterns

#### Data Distribution

Cities are distributed across states proportionally to actual population and urbanization:

| State | Code | Cities | State | Code | Cities |
|-------|------|--------|-------|------|--------|
| California | CA | 165 | Maryland | MD | 18 |
| Texas | TX | 130 | Wisconsin | WI | 17 |
| Florida | FL | 85 | Colorado | CO | 16 |
| New York | NY | 65 | Minnesota | MN | 15 |
| Pennsylvania | PA | 55 | South Carolina | SC | 14 |
| Illinois | IL | 50 | Alabama | AL | 13 |
| Ohio | OH | 45 | Louisiana | LA | 12 |
| Georgia | GA | 40 | Kentucky | KY | 11 |
| North Carolina | NC | 38 | Oregon | OR | 10 |
| Michigan | MI | 35 | Oklahoma | OK | 10 |
| New Jersey | NJ | 30 | Connecticut | CT | 9 |
| Virginia | VA | 28 | Utah | UT | 9 |
| Washington | WA | 26 | Iowa | IA | 8 |
| Arizona | AZ | 24 | Nevada | NV | 8 |
| Massachusetts | MA | 23 | Arkansas | AR | 7 |
| Tennessee | TN | 22 | Mississippi | MS | 7 |
| Indiana | IN | 20 | Kansas | KS | 7 |
| Missouri | MO | 19 | New Mexico | NM | 6 |
| Nebraska | NE | 6 | North Dakota | ND | 3 |
| West Virginia | WV | 5 | Alaska | AK | 3 |
| Idaho | ID | 5 | Vermont | VT | 3 |
| Hawaii | HI | 5 | Wyoming | WY | 2 |
| New Hampshire | NH | 5 | | | |
| Maine | ME | 4 | | | |
| Rhode Island | RI | 4 | | | |
| Montana | MT | 4 | | | |
| Delaware | DE | 3 | | | |
| South Dakota | SD | 3 | | | |

**Total: 1,000 cities across 50 states**

#### Features

1. **Realistic City Names**:
   - Major cities use real names (e.g., Los Angeles, Houston, Miami)
   - Generated cities use realistic naming patterns (e.g., Springville, Oaktown)
   - Unique names within each state

2. **Geographical Coordinates**:
   - Each city has latitude and longitude
   - Coordinates are within actual state boundaries
   - Supports location-based queries and geocoding features

3. **Data Relationships**:
   - Country → States → Cities hierarchy
   - Proper foreign keys and associations
   - SEO-friendly slugs generated automatically

4. **Clean Execution**:
   - Removes existing US data before seeding
   - Progress indicator during execution
   - Summary report upon completion

#### Example Output

```bash
🚀 Starting US data seeding...
================================================================================

🗑️  Cleaning up existing data...

🌎 Creating country...
   ✓ Created: United States (US)

📊 Total cities to be created: 1000

🏛️  Creating states and cities...
   Progress: 50/50 states, 1000/1000 cities

================================================================================

✅ US data seeding completed successfully!

📈 Summary:
   • Country: 1
   • States: 50
   • Cities: 1000

================================================================================
```

#### Database Schema

The task populates the following tables:

```ruby
# countries
- id: bigint (primary key)
- name: string
- code: string (2 chars, unique)
- slug: string (unique)
- created_at: datetime
- updated_at: datetime

# states
- id: bigint (primary key)
- country_id: bigint (foreign key)
- name: string
- code: string (10 chars max)
- slug: string (unique within country)
- created_at: datetime
- updated_at: datetime

# cities
- id: bigint (primary key)
- state_id: bigint (foreign key)
- name: string
- slug: string (unique within state)
- latitude: decimal(10,6)
- longitude: decimal(10,6)
- created_at: datetime
- updated_at: datetime
```

#### Use Cases

This data is useful for:

1. **Location-based Services**: Find companies near specific coordinates
2. **Geographical Filtering**: Filter companies by state or city
3. **Service Area Management**: Define company service coverage
4. **SEO-friendly URLs**: Use state/city slugs in routes
5. **Testing**: Provide realistic test data for development

#### Related Models

```ruby
# Country Model
Country.find_by(code: 'US')
Country.includes(:states, :cities)

# State Model
State.find_by(code: 'CA')
State.where(country: country)

# City Model
City.find_by(slug: 'los-angeles-0')
City.near([latitude, longitude], 25) # within 25 miles
```

#### Cleanup and Re-seeding

To clean up and re-seed the data:

```bash
# Clean all data and re-seed
bundle exec rake db:reset
bundle exec rake db:seed:us_data

# Or just re-run the task (it cleans US data automatically)
bundle exec rake db:seed:us_data
```

#### Performance

- **Execution Time**: Approximately 10-30 seconds depending on system
- **Database Size**: 
  - 1 country record
  - 50 state records
  - 1,000 city records
  - Total: ~1,051 records

#### Notes

- The task is idempotent - it cleans existing US data before seeding
- City coordinates are approximate and within state boundaries
- Real city names are used for major metropolitan areas
- Generated city names follow realistic US naming patterns
- All records include SEO-friendly slugs

#### Troubleshooting

**Issue**: Task fails with foreign key constraint errors

**Solution**: Ensure no companies or other related data exists:

```bash
# Clean all data first
bundle exec rake db:reset
bundle exec rake db:seed:us_data
```

**Issue**: Duplicate slug errors

**Solution**: The task should handle this automatically, but if it persists:

```bash
# Clear all location data manually
rails console
> City.destroy_all
> State.destroy_all
> Country.destroy_all
```

#### Future Enhancements

Potential improvements for this task:

- [ ] Add more countries (Canada, UK, Australia)
- [ ] Support for custom city distribution
- [ ] Import real city data from external APIs
- [ ] Add postal codes/ZIP codes
- [ ] Include county/region information
- [ ] Support for metropolitan areas

---

## 2. Seed Companies

This rake task creates 2000 realistic company records distributed across all cities in the database.

### Usage

```bash
# Run the companies seeding task
bundle exec rake db:seed:companies
```

**Prerequisites:**
- Must have cities in the database (run `rake db:seed:us_data` first)

### What it Creates

- **2000 Companies**: Distributed proportionally across all available cities
- **8 Service Categories**: Standard sewer/plumbing service types
- **Service Associations**: Each company offers 1-4 services
- **Service Areas**: Each company serves 1-5 nearby cities

### Company Data Features

#### Realistic Business Names
Companies are generated with professional naming patterns:
- **Format**: `[Prefix] + [Service Type] + [Suffix]`
- **Examples**: 
  - "Advanced Sewer Solutions"
  - "Elite Plumbing Experts"
  - "Quick Drain Services"
  - "AAA Rooter Pros"

#### Complete Contact Information
- **Phone Numbers**: Realistic US format (555-XXX-XXXX)
- **Email Addresses**: Generated from company name
- **Websites**: Professional domain names
- **Street Addresses**: Realistic street numbers and names

#### Geographical Data
- **Coordinates**: Latitude/longitude near city center (±5km variance)
- **Addresses**: Realistic street addresses with ZIP codes
- **Service Areas**: Companies serve their home city plus 1-5 nearby cities in same state

#### Business Attributes
Each company has randomized attributes based on realistic distributions:

| Attribute | Probability | Description |
|-----------|-------------|-------------|
| Premium Service Level | 30% | Elite or Premium tier |
| Certified Partner | 40% | Certified by industry organizations |
| Licensed | 60% | State licensed contractor |
| Insured | 70% | Liability insurance |
| Service Guarantee | 50% | Offers satisfaction guarantee |
| Background Checked | 50% | Employee background checks |
| Verified Professional | 40% | Platform verified status |

#### Service Categories

The task creates these service categories:

1. **Sewer Line Repair** - Professional sewer line repair and replacement services
2. **Drain Cleaning** - Expert drain cleaning and unclogging services
3. **Pipe Inspection** - Video camera pipe inspection services
4. **Trenchless Repair** - Modern trenchless sewer repair technology
5. **Emergency Services** - 24/7 emergency plumbing services
6. **Septic Systems** - Septic tank installation and maintenance
7. **Water Line Repair** - Water line repair and replacement
8. **Hydro Jetting** - High-pressure water jetting services

### Example Output

```bash
🚀 Starting company seeding...
================================================================================

📊 Database status:
   • Cities available: 1152
   • Current companies: 0

🏷️  Ensuring service categories exist...
   ✓ Service categories ready: 8

⚠️  This task will create 2000 new companies.
   Press Ctrl+C to cancel, or wait 3 seconds to continue...

🏢 Creating companies...
   Progress: 2000/2000 companies created

================================================================================

✅ Company seeding completed!

📈 Summary:
   • Companies created: 2000
   • Total companies in DB: 2000
   • Distribution: ~1.74 companies per city (average)

💡 Tips:
   • Add reviews: rake db:seed:reviews
   • Add certifications: rake db:seed:certifications
   • Add gallery images: rake db:seed:gallery_images

================================================================================
```

### Distribution Algorithm

Companies are distributed across cities using a smart algorithm:

1. **Round-robin base**: Companies are assigned to cities sequentially
2. **Random variance**: 30% of assignments use random cities for realistic clustering
3. **State-aware service areas**: Companies serve nearby cities within same state
4. **Unique names**: Ensures no duplicate company names within same city

### Database Schema

The task populates these tables:

```ruby
# companies
- id: bigint (primary key)
- city_id: bigint (foreign key)
- name: string (unique within city)
- slug: string (unique within city)
- description: text
- phone: string
- email: string
- website: string
- street_address: string
- zip_code: string
- latitude: decimal(10,6)
- longitude: decimal(10,6)
- specialty: string
- service_level: string
- certified_partner: boolean
- licensed: boolean
- insured: boolean
- service_guarantee: boolean
- background_checked: boolean
- verified_professional: boolean
- average_rating: decimal(3,2)
- total_reviews: integer
- created_at: datetime
- updated_at: datetime

# service_categories
- id: bigint (primary key)
- name: string (unique)
- slug: string (unique)
- description: text
- created_at: datetime
- updated_at: datetime

# company_services (join table)
- id: bigint (primary key)
- company_id: bigint (foreign key)
- service_category_id: bigint (foreign key)
- created_at: datetime
- updated_at: datetime

# company_service_areas (join table)
- id: bigint (primary key)
- company_id: bigint (foreign key)
- city_id: bigint (foreign key)
- created_at: datetime
- updated_at: datetime
```

### Use Cases

This data is useful for:

1. **API Testing**: Test search, filtering, and pagination endpoints
2. **Performance Testing**: Benchmark queries with realistic data volumes
3. **UI Development**: Populate frontend interfaces with realistic companies
4. **Location-based Features**: Test geographical search and proximity queries
5. **Demo Purposes**: Showcase the platform to stakeholders

### Related Queries

```ruby
# Find companies in a specific city
City.find_by(name: 'Los Angeles').companies

# Find companies offering specific service
ServiceCategory.find_by(name: 'Sewer Line Repair').companies

# Find nearby companies (within 25 miles)
Company.near([latitude, longitude], 25)

# Premium certified companies
Company.where(certified_partner: true, service_level: ['Premium', 'Elite'])

# Companies with service guarantees
Company.where(service_guarantee: true, licensed: true, insured: true)
```

### Cleanup and Re-seeding

To clean up and re-seed companies:

```bash
# Delete all companies and related data
rails console
> Company.destroy_all
> ServiceCategory.destroy_all

# Or reset entire database
bundle exec rake db:reset

# Seed locations first
bundle exec rake db:seed:us_data

# Then seed companies
bundle exec rake db:seed:companies
```

### Performance

- **Execution Time**: Approximately 2-5 minutes for 2000 companies
- **Database Size**: 
  - 2000 company records
  - 8 service category records
  - ~5000 company_service records (avg 2.5 services per company)
  - ~6000 company_service_area records (avg 3 areas per company)
  - **Total**: ~13,000+ records

### Advanced Options

You can modify the task to customize the seeding:

```ruby
# In lib/tasks/seed_companies.rake, change:
companies_to_create = 2000  # Change to desired number

# Adjust service distribution:
num_services = rand(1..4)  # Change range for services per company

# Adjust service area distribution:
num_areas = rand(1..5)  # Change range for service areas
```

### Error Handling

The task includes comprehensive error handling:

- **No cities found**: Exits with helpful message
- **Duplicate names**: Automatically generates unique names
- **Validation errors**: Collects and reports at end
- **Database errors**: Displays first 5 errors for debugging

### Troubleshooting

**Issue**: Task fails with "No cities found"

**Solution**: Run the US data seeding first:
```bash
bundle exec rake db:seed:us_data
```

**Issue**: Duplicate slug errors

**Solution**: The task handles this automatically, but if it persists:
```bash
rails console
> Company.where('name LIKE ?', '%duplicate_name%').destroy_all
```

**Issue**: Out of memory errors with large datasets

**Solution**: Reduce batch size or total companies:
```ruby
companies_to_create = 1000  # Reduce from 2000
```

### Next Steps

After seeding companies, enhance your data with:

```bash
# Add customer reviews (coming soon)
bundle exec rake db:seed:reviews

# Add company certifications (coming soon)
bundle exec rake db:seed:certifications

# Add gallery images (coming soon)
bundle exec rake db:seed:gallery_images
```

---

## Complete Workflow

To set up a complete test database:

```bash
# 1. Reset database (optional, if starting fresh)
bundle exec rake db:reset

# 2. Run migrations
bundle exec rake db:migrate

# 3. Seed geographical data
bundle exec rake db:seed:us_data

# 4. Seed companies
bundle exec rake db:seed:companies

# 5. (Optional) Seed additional data
# bundle exec rake db:seed:reviews
# bundle exec rake db:seed:certifications
```

---

## Future Enhancements

Potential improvements for this task:

- [ ] Add more countries (Canada, UK, Australia)
- [ ] Support for custom city distribution
- [ ] Import real city data from external APIs
- [ ] Add postal codes/ZIP codes
- [ ] Include county/region information
- [ ] Support for metropolitan areas

