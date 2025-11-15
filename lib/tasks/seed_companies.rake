# frozen_string_literal: true

namespace :db do
  namespace :seed do
    desc 'Seed 2000 companies distributed across all cities'
    task companies: :environment do
      puts '🚀 Starting company seeding...'
      puts '=' * 80

      # Check if we have cities
      total_cities = City.count
      if total_cities.zero?
        puts "\n❌ Error: No cities found in database!"
        puts "   Please run 'rake db:seed:us_data' first to create cities."
        exit 1
      end

      puts "\n📊 Database status:"
      puts "   • Cities available: #{total_cities}"
      puts "   • Current companies: #{Company.count}"

      # Create service categories if they don't exist
      puts "\n🏷️  Ensuring service categories exist..."
      service_categories = ensure_service_categories
      puts "   ✓ Service categories ready: #{service_categories.count}"

      # Configuration
      companies_to_create = 2000

      puts "\n⚠️  This task will create #{companies_to_create} new companies."
      puts '   Press Ctrl+C to cancel, or wait 3 seconds to continue...'
      sleep 3

      # Get all cities and distribute companies
      cities = City.includes(:state).all.to_a
      puts "\n🏢 Creating companies..."

      companies_created = 0
      errors = []

      # Company name components for realistic business names
      prefixes = %w[
        Advanced Professional Expert Elite Premier Quality Reliable
        Quick Fast Best Top Certified Licensed Master Superior
        A-1 AAA Precision Perfect Classic Modern Metro City
      ]

      services = %w[
        Sewer Plumbing Drain Pipe Rooter Septic Wastewater
      ]

      suffixes = %w[
        Services Solutions Specialists Experts Pros Company
        Contractors Repair Care Works Masters Team
      ]

      specialties = [
        'Sewer Line Repair',
        'Drain Cleaning',
        'Pipe Replacement',
        'Trenchless Technology',
        'Emergency Services',
        'Residential Plumbing',
        'Commercial Plumbing',
        'Septic Services'
      ]

      service_levels = %w[Basic Standard Premium Elite]

      # Create companies in batches
      companies_to_create.times do |i|
        # Distribute companies across cities (round-robin with some randomness)
        city = cities[i % cities.length]

        # Occasionally pick a random city for variety
        city = cities.sample if rand < 0.3

        # Generate company name
        prefix = prefixes.sample
        service = services.sample
        suffix = suffixes.sample
        company_name = "#{prefix} #{service} #{suffix}"

        # Ensure unique name within city
        counter = 1
        base_name = company_name
        while Company.exists?(name: company_name, city_id: city.id)
          company_name = "#{base_name} #{counter}"
          counter += 1
        end

        # Generate street address
        street_number = rand(100..9999)
        street_names = ['Main St', 'Oak Ave', 'Pine St', 'Maple Dr', 'Cedar Ln', 'Elm St',
                        'Washington St', 'Park Ave', 'Broadway', 'First St', 'Second Ave']
        street_address = "#{street_number} #{street_names.sample}"

        # Generate coordinates near the city
        lat_offset = (rand - 0.5) * 0.1 # ±0.05 degrees (~5.5 km)
        lng_offset = (rand - 0.5) * 0.1
        latitude = (city.latitude + lat_offset).round(6) if city.latitude
        longitude = (city.longitude + lng_offset).round(6) if city.longitude

        # Random attributes
        is_premium = rand < 0.3
        is_certified = rand < 0.4
        is_licensed = rand < 0.6
        is_insured = rand < 0.7
        has_guarantee = rand < 0.5
        is_background_checked = rand < 0.5
        is_verified = rand < 0.4

        # Create company
        company = Company.new(
          name: company_name,
          city: city,
          description: generate_description(company_name, city, service.downcase),
          phone: generate_phone,
          email: generate_email(company_name),
          website: generate_website(company_name),
          street_address: street_address,
          zip_code: generate_zip_code,
          latitude: latitude,
          longitude: longitude,
          specialty: specialties.sample,
          service_level: is_premium ? service_levels[2..3].sample : service_levels[0..1].sample,
          certified_partner: is_certified,
          licensed: is_licensed,
          insured: is_insured,
          service_guarantee: has_guarantee,
          background_checked: is_background_checked,
          verified_professional: is_verified,
          average_rating: 0,
          total_reviews: 0
        )

        if company.save
          companies_created += 1

          # Add 1-4 service categories
          num_services = rand(1..4)
          company.service_categories << service_categories.sample(num_services)

          # Add service areas (1-5 nearby cities)
          num_areas = rand(1..5)
          nearby_cities = cities.select { |c| c.state_id == city.state_id }.sample(num_areas)
          nearby_cities.each do |nearby_city|
            CompanyServiceArea.create(company: company, city: nearby_city) unless nearby_city.id == city.id
          end

          print "\r   Progress: #{companies_created}/#{companies_to_create} companies created"
        else
          errors << { name: company_name, errors: company.errors.full_messages }
        end
      end

      puts "\n"
      puts '=' * 80
      puts "\n✅ Company seeding completed!"
      puts "\n📈 Summary:"
      puts "   • Companies created: #{companies_created}"
      puts "   • Total companies in DB: #{Company.count}"
      puts "   • Distribution: ~#{(companies_created.to_f / total_cities).round(2)} companies per city (average)"

      if errors.any?
        puts "\n⚠️  Errors encountered: #{errors.count}"
        puts '   First 5 errors:'
        errors.take(5).each do |error|
          puts "   - #{error[:name]}: #{error[:errors].join(', ')}"
        end
      end

      puts "\n💡 Tips:"
      puts '   • Add reviews: rake db:seed:reviews'
      puts '   • Add certifications: rake db:seed:certifications'
      puts '   • Add gallery images: rake db:seed:gallery_images'
      puts "\n#{'=' * 80}"
    end

    # Helper methods
    def ensure_service_categories
      categories = [
        { name: 'Sewer Line Repair', description: 'Professional sewer line repair and replacement services' },
        { name: 'Drain Cleaning', description: 'Expert drain cleaning and unclogging services' },
        { name: 'Pipe Inspection', description: 'Video camera pipe inspection services' },
        { name: 'Trenchless Repair', description: 'Modern trenchless sewer repair technology' },
        { name: 'Emergency Services', description: '24/7 emergency plumbing services' },
        { name: 'Septic Systems', description: 'Septic tank installation and maintenance' },
        { name: 'Water Line Repair', description: 'Water line repair and replacement' },
        { name: 'Hydro Jetting', description: 'High-pressure water jetting services' }
      ]

      categories.map do |cat_data|
        ServiceCategory.find_or_create_by!(name: cat_data[:name]) do |cat|
          cat.description = cat_data[:description]
        end
      end
    end

    def generate_description(company_name, city, service_type)
      templates = [
        "#{company_name} has been serving #{city.name} and surrounding areas for years. We specialize in #{service_type} services and are committed to providing quality workmanship.",
        "Looking for reliable #{service_type} services in #{city.name}? #{company_name} offers professional solutions with experienced technicians and competitive pricing.",
        "#{company_name} is your trusted #{service_type} expert in #{city.name}. We provide fast, reliable service with a satisfaction guarantee.",
        "Serving #{city.name} and the greater #{city.state.name} area, #{company_name} delivers exceptional #{service_type} services with professional results.",
        "#{company_name} provides comprehensive #{service_type} solutions for residential and commercial properties in #{city.name}. Licensed, insured, and ready to help."
      ]
      templates.sample
    end

    def generate_phone
      area_codes = %w[555 442 213 310 415 510 619 714 818 916]
      "#{area_codes.sample}-#{rand(200..999)}-#{rand(1000..9999)}"
    end

    def generate_email(company_name)
      domain_prefixes = %w[info contact service office]
      domains = ['plumbing.com', 'sewerrepair.com', 'services.com', 'pro.com']
      slug = company_name.parameterize
      "#{domain_prefixes.sample}@#{slug.split('-').first(2).join}#{domains.sample}"
    end

    def generate_website(company_name)
      slug = company_name.parameterize
      "https://www.#{slug.split('-').first(3).join}.com"
    end

    def generate_zip_code
      rand(10_000..99_999).to_s
    end
  end
end
