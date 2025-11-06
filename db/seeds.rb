# frozen_string_literal: true

# Clear existing data
puts "Clearing existing data..."
Certification.destroy_all
GalleryImage.destroy_all
CompanyService.destroy_all
CompanyServiceArea.destroy_all
Review.destroy_all
Company.destroy_all
ServiceCategory.destroy_all
City.destroy_all
State.destroy_all
Country.destroy_all

puts "Creating countries..."
usa = Country.create!(
  name: "United States",
  code: "US"
)

puts "Creating states..."
florida = usa.states.create!(name: "Florida", code: "FL")
texas = usa.states.create!(name: "Texas", code: "TX")
california = usa.states.create!(name: "California", code: "CA")

puts "Creating cities..."
# Florida cities
orlando = florida.cities.create!(name: "Orlando", latitude: 28.5383, longitude: -81.3792)
miami = florida.cities.create!(name: "Miami", latitude: 25.7617, longitude: -80.1918)
tampa = florida.cities.create!(name: "Tampa", latitude: 27.9506, longitude: -82.4572)
jacksonville = florida.cities.create!(name: "Jacksonville", latitude: 30.3322, longitude: -81.6557)
tallahassee = florida.cities.create!(name: "Tallahassee", latitude: 30.4383, longitude: -84.2807)

# Texas cities
houston = texas.cities.create!(name: "Houston", latitude: 29.7604, longitude: -95.3698)
dallas = texas.cities.create!(name: "Dallas", latitude: 32.7767, longitude: -96.7970)
austin = texas.cities.create!(name: "Austin", latitude: 30.2672, longitude: -97.7431)
san_antonio = texas.cities.create!(name: "San Antonio", latitude: 29.4241, longitude: -98.4936)
fort_worth = texas.cities.create!(name: "Fort Worth", latitude: 32.7555, longitude: -97.3308)

# California cities
los_angeles = california.cities.create!(name: "Los Angeles", latitude: 34.0522, longitude: -118.2437)
san_diego = california.cities.create!(name: "San Diego", latitude: 32.7157, longitude: -117.1611)
san_francisco = california.cities.create!(name: "San Francisco", latitude: 37.7749, longitude: -122.4194)
sacramento = california.cities.create!(name: "Sacramento", latitude: 38.5816, longitude: -121.4944)
san_jose = california.cities.create!(name: "San Jose", latitude: 37.3382, longitude: -121.8863)

puts "Creating service categories..."
sewer_repair = ServiceCategory.create!(
  name: "Sewer Line Repair",
  description: "Complete sewer line repair and replacement services"
)
drain_cleaning = ServiceCategory.create!(
  name: "Drain Cleaning",
  description: "Professional drain cleaning and unclogging services"
)
camera_inspection = ServiceCategory.create!(
  name: "Camera Inspection",
  description: "Video camera inspection of sewer and drain lines"
)
trenchless_repair = ServiceCategory.create!(
  name: "Trenchless Repair",
  description: "No-dig sewer line repair using trenchless technology"
)
hydro_jetting = ServiceCategory.create!(
  name: "Hydro Jetting",
  description: "High-pressure water jetting for thorough pipe cleaning"
)

puts "Creating companies..."
cities = [orlando, miami, tampa, houston, dallas, austin, los_angeles, san_diego, san_francisco]
company_names = [
  "Elite Sewer Solutions",
  "ProPlumb Experts",
  "Drain Masters Inc",
  "Rapid Rooter Service",
  "Premium Pipe Pros",
  "Sewer Rescue Team",
  "All-Clear Plumbing",
  "TrustFlow Services",
  "Underground Experts",
  "Pipeline Specialists"
]

companies = []
cities.each_with_index do |city, idx|
  company = Company.create!(
    city: city,
    name: company_names[idx],
    phone: "(#{rand(200..999)}) #{rand(200..999)}-#{rand(1000..9999)}",
    email: "contact@#{company_names[idx].parameterize}.com",
    website: "https://www.#{company_names[idx].parameterize}.com",
    street_address: "#{rand(100..9999)} #{['Main', 'Oak', 'Pine', 'Maple', 'Cedar'].sample} St",
    zip_code: "#{rand(10000..99999)}",
    latitude: city.latitude + rand(-0.1..0.1),
    longitude: city.longitude + rand(-0.1..0.1),
    specialty: ["Residential", "Commercial", "Industrial", "Emergency Services"].sample,
    service_level: ["Basic", "Standard", "Premium", "Elite"].sample,
    description: "Professional sewer and drain services with over #{rand(5..25)} years of experience. Licensed, insured, and available 24/7 for emergency services.",
    verified_professional: [true, false].sample,
    certified_partner: [true, false].sample,
    licensed: true,
    insured: true,
    background_checked: [true, false].sample,
    service_guarantee: [true, false].sample
  )
  companies << company

  # Add service categories
  ServiceCategory.order("RANDOM()").limit(rand(2..4)).each do |category|
    company.company_services.create!(service_category: category)
  end

  # Add service areas (nearby cities)
  nearby_cities = cities.select { |c| c.state_id == city.state_id && c.id != city.id }
  nearby_cities.sample(rand(1..3)).each do |nearby_city|
    company.company_service_areas.create!(city: nearby_city)
  end
end

puts "Creating reviews..."
companies.each do |company|
  rand(5..15).times do
    review = company.reviews.create!(
      reviewer_name: ["John Smith", "Sarah Johnson", "Michael Brown", "Emily Davis", "David Wilson", "Jennifer Martinez", "Robert Taylor", "Lisa Anderson"].sample,
      review_date: rand(1..365).days.ago.to_date,
      rating: rand(3..5),
      review_text: [
        "Excellent service! Very professional and thorough.",
        "Quick response time and fair pricing. Highly recommend!",
        "They fixed our sewer line issue quickly and efficiently.",
        "Professional team, great communication throughout the process.",
        "Very satisfied with the quality of work and attention to detail.",
        "Emergency service was fast and reliable. Thank you!",
        "Fair pricing and excellent customer service.",
        "Highly skilled technicians who know what they're doing."
      ].sample,
      verified: [true, true, true, false].sample
    )
  end
  company.update_rating!
end

puts "Creating gallery images..."
companies.each do |company|
  image_types = %w[before after work team equipment]
  rand(3..7).times do |i|
    company.gallery_images.create!(
      title: ["Project #{i+1}", "Recent Work", "Completed Job", "Service Call"].sample,
      description: "Professional sewer line repair completed successfully",
      image_url: "https://placehold.co/800x600/png?text=Gallery+Image+#{i+1}",
      thumbnail_url: "https://placehold.co/200x150/png?text=Thumb+#{i+1}",
      image_type: image_types.sample,
      position: i
    )
  end
end

puts "Creating certifications..."
cert_names = [
  "Master Plumber License",
  "EPA Lead-Safe Certification",
  "OSHA Safety Training",
  "Backflow Prevention Certification",
  "Trenchless Technology Certification",
  "Green Plumber Certification",
  "Water Quality Association Certification"
]

companies.each do |company|
  rand(1..3).times do
    company.certifications.create!(
      certification_name: cert_names.sample,
      issuing_organization: ["State Licensing Board", "EPA", "OSHA", "NASSCO", "WQA"].sample,
      issue_date: rand(1..5).years.ago.to_date,
      expiry_date: [nil, rand(1..3).years.from_now.to_date].sample,
      certificate_number: "CERT-#{rand(100000..999999)}",
      certificate_url: "https://example.com/certificates/#{rand(1000..9999)}"
    )
  end
end

puts "\n" + "="*60
puts "Seed data created successfully!"
puts "="*60
puts "Countries: #{Country.count}"
puts "States: #{State.count}"
puts "Cities: #{City.count}"
puts "Service Categories: #{ServiceCategory.count}"
puts "Companies: #{Company.count}"
puts "Reviews: #{Review.count}"
puts "Gallery Images: #{GalleryImage.count}"
puts "Certifications: #{Certification.count}"
puts "Company Services: #{CompanyService.count}"
puts "Company Service Areas: #{CompanyServiceArea.count}"
puts "="*60

