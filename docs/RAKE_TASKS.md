# Rake Tasks Documentation

## Database Seeding Tasks

### Seed US Data

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

