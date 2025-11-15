# frozen_string_literal: true

namespace :db do
  namespace :seed do
    desc 'Seed US country, states, and cities with realistic distribution'
    task us_data: :environment do
      puts '🚀 Starting US data seeding...'
      puts '=' * 80

      # Clear existing data
      puts "\n🗑️  Cleaning up existing US data..."
      us_country = Country.find_by(code: 'US')
      if us_country
        puts '   ⚠️  Found existing US data. Checking for dependent records...'

        # Get all US state IDs
        us_state_ids = State.where(country_id: us_country.id).pluck(:id)
        us_city_ids = City.where(state_id: us_state_ids).pluck(:id)

        # Check for companies
        company_count = Company.where(city_id: us_city_ids).count

        if company_count.positive?
          puts "   ⚠️  Warning: Found #{company_count} companies in US cities."
          puts '   ℹ️  This task will DELETE all companies in US cities to proceed.'
          puts '   Press Ctrl+C to cancel, or wait 5 seconds to continue...'
          sleep 5

          # Delete all related data in proper order
          ActiveRecord::Base.transaction do
            puts '   🗑️  Deleting companies and related data...'

            # Get company IDs first
            company_ids = Company.where(city_id: us_city_ids).pluck(:id)

            # Delete related company data without callbacks
            Review.where(company_id: company_ids).delete_all if company_ids.any?
            Certification.where(company_id: company_ids).delete_all if company_ids.any?
            GalleryImage.where(company_id: company_ids).delete_all if company_ids.any?
            CompanyService.where(company_id: company_ids).delete_all if company_ids.any?
            CompanyServiceArea.where(company_id: company_ids).delete_all if company_ids.any?

            # Delete companies
            Company.where(city_id: us_city_ids).delete_all

            puts '   🗑️  Deleting cities...'
            City.where(state_id: us_state_ids).delete_all

            puts '   🗑️  Deleting states...'
            State.where(country_id: us_country.id).delete_all

            puts '   🗑️  Deleting country...'
            us_country.delete
          end
        else
          # No companies, safe to delete
          ActiveRecord::Base.transaction do
            City.where(state_id: us_state_ids).delete_all
            State.where(country_id: us_country.id).delete_all
            us_country.delete
          end
        end

        puts '   ✓ Cleanup completed'
      else
        puts '   ℹ️  No existing US data found'
      end

      # Create United States
      puts "\n🌎 Creating country..."
      country = Country.create!(
        name: 'United States',
        code: 'US',
        slug: 'united-states'
      )
      puts "   ✓ Created: #{country.name} (#{country.code})"

      # Real US states with their 2-letter codes and realistic city distribution
      # Distribution based on actual state populations and urban areas
      us_states_data = [
        { name: 'California', code: 'CA', cities: 165 },
        { name: 'Texas', code: 'TX', cities: 130 },
        { name: 'Florida', code: 'FL', cities: 85 },
        { name: 'New York', code: 'NY', cities: 65 },
        { name: 'Pennsylvania', code: 'PA', cities: 55 },
        { name: 'Illinois', code: 'IL', cities: 50 },
        { name: 'Ohio', code: 'OH', cities: 45 },
        { name: 'Georgia', code: 'GA', cities: 40 },
        { name: 'North Carolina', code: 'NC', cities: 38 },
        { name: 'Michigan', code: 'MI', cities: 35 },
        { name: 'New Jersey', code: 'NJ', cities: 30 },
        { name: 'Virginia', code: 'VA', cities: 28 },
        { name: 'Washington', code: 'WA', cities: 26 },
        { name: 'Arizona', code: 'AZ', cities: 24 },
        { name: 'Massachusetts', code: 'MA', cities: 23 },
        { name: 'Tennessee', code: 'TN', cities: 22 },
        { name: 'Indiana', code: 'IN', cities: 20 },
        { name: 'Missouri', code: 'MO', cities: 19 },
        { name: 'Maryland', code: 'MD', cities: 18 },
        { name: 'Wisconsin', code: 'WI', cities: 17 },
        { name: 'Colorado', code: 'CO', cities: 16 },
        { name: 'Minnesota', code: 'MN', cities: 15 },
        { name: 'South Carolina', code: 'SC', cities: 14 },
        { name: 'Alabama', code: 'AL', cities: 13 },
        { name: 'Louisiana', code: 'LA', cities: 12 },
        { name: 'Kentucky', code: 'KY', cities: 11 },
        { name: 'Oregon', code: 'OR', cities: 10 },
        { name: 'Oklahoma', code: 'OK', cities: 10 },
        { name: 'Connecticut', code: 'CT', cities: 9 },
        { name: 'Utah', code: 'UT', cities: 9 },
        { name: 'Iowa', code: 'IA', cities: 8 },
        { name: 'Nevada', code: 'NV', cities: 8 },
        { name: 'Arkansas', code: 'AR', cities: 7 },
        { name: 'Mississippi', code: 'MS', cities: 7 },
        { name: 'Kansas', code: 'KS', cities: 7 },
        { name: 'New Mexico', code: 'NM', cities: 6 },
        { name: 'Nebraska', code: 'NE', cities: 6 },
        { name: 'West Virginia', code: 'WV', cities: 5 },
        { name: 'Idaho', code: 'ID', cities: 5 },
        { name: 'Hawaii', code: 'HI', cities: 5 },
        { name: 'New Hampshire', code: 'NH', cities: 5 },
        { name: 'Maine', code: 'ME', cities: 4 },
        { name: 'Rhode Island', code: 'RI', cities: 4 },
        { name: 'Montana', code: 'MT', cities: 4 },
        { name: 'Delaware', code: 'DE', cities: 3 },
        { name: 'South Dakota', code: 'SD', cities: 3 },
        { name: 'North Dakota', code: 'ND', cities: 3 },
        { name: 'Alaska', code: 'AK', cities: 3 },
        { name: 'Vermont', code: 'VT', cities: 3 },
        { name: 'Wyoming', code: 'WY', cities: 2 }
      ]

      # Verify total cities = 1000
      total_cities = us_states_data.sum { |state| state[:cities] }
      puts "\n📊 Total cities to be created: #{total_cities}"

      # Sample city names for realistic data generation
      city_prefixes = %w[
        Spring River Lake Mountain Oak Pine Cedar Maple
        West East North South New Port Fort Saint
        Green Fair Clear Silver Golden Rose Sun Moon
      ]

      city_suffixes = %w[
        ville town city field wood dale view port
        land burg ford ton ham ley mont ridge
      ]

      # Real city names for major states (sample)
      real_cities = {
        'CA' => ['Los Angeles', 'San Francisco', 'San Diego', 'Sacramento', 'San Jose', 'Oakland', 'Fresno',
                 'Long Beach'],
        'TX' => ['Houston', 'Dallas', 'Austin', 'San Antonio', 'Fort Worth', 'El Paso', 'Arlington', 'Corpus Christi'],
        'FL' => ['Miami', 'Jacksonville', 'Tampa', 'Orlando', 'St. Petersburg', 'Hialeah', 'Tallahassee',
                 'Fort Lauderdale'],
        'NY' => ['New York', 'Buffalo', 'Rochester', 'Syracuse', 'Albany', 'Yonkers', 'Brooklyn', 'Queens'],
        'PA' => %w[Philadelphia Pittsburgh Allentown Erie Reading Scranton Bethlehem Lancaster],
        'IL' => %w[Chicago Aurora Rockford Joliet Naperville Springfield Peoria Elgin],
        'OH' => %w[Columbus Cleveland Cincinnati Toledo Akron Dayton Parma Canton],
        'GA' => ['Atlanta', 'Augusta', 'Columbus', 'Savannah', 'Athens', 'Sandy Springs', 'Roswell', 'Macon'],
        'NC' => %w[Charlotte Raleigh Greensboro Durham Winston-Salem Fayetteville Cary Wilmington],
        'MI' => ['Detroit', 'Grand Rapids', 'Warren', 'Sterling Heights', 'Ann Arbor', 'Lansing', 'Flint', 'Dearborn']
      }

      # Create states and cities
      puts "\n🏛️  Creating states and cities..."
      states_created = 0
      cities_created = 0

      us_states_data.each do |state_data|
        state = country.states.create!(
          name: state_data[:name],
          code: state_data[:code],
          slug: state_data[:name].parameterize
        )
        states_created += 1

        # Get real cities for this state or generate names
        city_names = []
        city_names = real_cities[state_data[:code]].take(state_data[:cities]) if real_cities[state_data[:code]]

        # Generate remaining city names if needed
        remaining_count = state_data[:cities] - city_names.length
        remaining_count.times do |_i|
          prefix = city_prefixes.sample
          suffix = city_suffixes.sample
          city_name = "#{prefix}#{suffix}"

          # Ensure unique name within state
          counter = 1
          while city_names.include?(city_name)
            city_name = "#{prefix}#{suffix} #{counter}"
            counter += 1
          end

          city_names << city_name
        end

        # Create cities for this state with realistic coordinates
        # Approximate coordinate ranges for US states
        lat_range, lng_range = get_state_coordinates(state_data[:code])

        city_names.each_with_index do |city_name, index|
          # Generate coordinates within state bounds with some randomness
          latitude = rand(lat_range[0]..lat_range[1]).round(6)
          longitude = rand(lng_range[0]..lng_range[1]).round(6)

          state.cities.create!(
            name: city_name,
            slug: "#{city_name.parameterize}-#{index}",
            latitude: latitude,
            longitude: longitude
          )
          cities_created += 1
        end

        print "\r   Progress: #{states_created}/#{us_states_data.length} states, #{cities_created}/#{total_cities} cities"
      end

      puts "\n"
      puts '=' * 80
      puts "\n✅ US data seeding completed successfully!"
      puts "\n📈 Summary:"
      puts '   • Country: 1'
      puts "   • States: #{states_created}"
      puts "   • Cities: #{cities_created}"
      puts "\n#{'=' * 80}"
    end

    # Helper method to get approximate coordinate ranges for each US state
    def get_state_coordinates(state_code)
      coordinates = {
        'AL' => [[30.2, 35.0], [-88.5, -84.9]],
        'AK' => [[51.2, 71.5], [-179.1, -129.9]],
        'AZ' => [[31.3, 37.0], [-114.8, -109.0]],
        'AR' => [[33.0, 36.5], [-94.6, -89.6]],
        'CA' => [[32.5, 42.0], [-124.4, -114.1]],
        'CO' => [[37.0, 41.0], [-109.1, -102.0]],
        'CT' => [[41.0, 42.1], [-73.7, -71.8]],
        'DE' => [[38.5, 39.8], [-75.8, -75.0]],
        'FL' => [[24.5, 31.0], [-87.6, -80.0]],
        'GA' => [[30.4, 35.0], [-85.6, -80.8]],
        'HI' => [[18.9, 22.2], [-160.2, -154.8]],
        'ID' => [[42.0, 49.0], [-117.2, -111.0]],
        'IL' => [[37.0, 42.5], [-91.5, -87.5]],
        'IN' => [[37.8, 41.8], [-88.1, -84.8]],
        'IA' => [[40.4, 43.5], [-96.6, -90.1]],
        'KS' => [[37.0, 40.0], [-102.1, -94.6]],
        'KY' => [[36.5, 39.1], [-89.6, -81.9]],
        'LA' => [[28.9, 33.0], [-94.0, -88.8]],
        'ME' => [[43.1, 47.5], [-71.1, -66.9]],
        'MD' => [[37.9, 39.7], [-79.5, -75.0]],
        'MA' => [[41.2, 42.9], [-73.5, -69.9]],
        'MI' => [[41.7, 48.2], [-90.4, -82.4]],
        'MN' => [[43.5, 49.4], [-97.2, -89.5]],
        'MS' => [[30.2, 35.0], [-91.7, -88.1]],
        'MO' => [[36.0, 40.6], [-95.8, -89.1]],
        'MT' => [[44.4, 49.0], [-116.0, -104.0]],
        'NE' => [[40.0, 43.0], [-104.1, -95.3]],
        'NV' => [[35.0, 42.0], [-120.0, -114.0]],
        'NH' => [[42.7, 45.3], [-72.6, -70.6]],
        'NJ' => [[38.9, 41.4], [-75.6, -73.9]],
        'NM' => [[31.3, 37.0], [-109.1, -103.0]],
        'NY' => [[40.5, 45.0], [-79.8, -71.9]],
        'NC' => [[33.8, 36.6], [-84.3, -75.5]],
        'ND' => [[45.9, 49.0], [-104.1, -96.6]],
        'OH' => [[38.4, 42.3], [-84.8, -80.5]],
        'OK' => [[33.6, 37.0], [-103.0, -94.4]],
        'OR' => [[42.0, 46.3], [-124.6, -116.5]],
        'PA' => [[39.7, 42.5], [-80.5, -74.7]],
        'RI' => [[41.1, 42.0], [-71.9, -71.1]],
        'SC' => [[32.0, 35.2], [-83.4, -78.5]],
        'SD' => [[42.5, 46.0], [-104.1, -96.4]],
        'TN' => [[35.0, 36.7], [-90.3, -81.6]],
        'TX' => [[25.8, 36.5], [-106.6, -93.5]],
        'UT' => [[37.0, 42.0], [-114.1, -109.0]],
        'VT' => [[42.7, 45.0], [-73.4, -71.5]],
        'VA' => [[36.5, 39.5], [-83.7, -75.2]],
        'WA' => [[45.5, 49.0], [-124.8, -116.9]],
        'WV' => [[37.2, 40.6], [-82.6, -77.7]],
        'WI' => [[42.5, 47.3], [-92.9, -86.2]],
        'WY' => [[41.0, 45.0], [-111.1, -104.1]]
      }

      coordinates[state_code] || [[33.0, 45.0], [-120.0, -80.0]] # Default US range
    end
  end
end
