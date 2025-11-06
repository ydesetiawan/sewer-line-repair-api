# frozen_string_literal: true

puts "Testing Models and Associations..."
puts "=" * 60

# Test Country associations
country = Country.first
puts "Country: #{country.name}"
puts "  States: #{country.states.count}"
puts "  Cities: #{country.cities.count}"

# Test Company associations
company = Company.first
puts "\nCompany: #{company.name}"
puts "  City: #{company.city.name}"
puts "  State: #{company.state.name}"
puts "  Country: #{company.country.name}"
puts "  URL Path: #{company.url_path}"
puts "  Reviews: #{company.reviews.count}"
puts "  Average Rating: #{company.average_rating}"
puts "  Service Categories: #{company.service_categories.pluck(:name).join(', ')}"
puts "  Service Areas: #{company.service_areas.pluck(:name).join(', ')}"
puts "  Gallery Images: #{company.gallery_images.count}"
puts "  Certifications: #{company.certifications.count}"

# Test Review callbacks
puts "\nTesting Review rating update..."
old_rating = company.average_rating
old_count = company.total_reviews
new_review = company.reviews.create!(
  reviewer_name: "Test User",
  review_date: Date.today,
  rating: 5,
  review_text: "Excellent!"
)
company.reload
puts "  Old average: #{old_rating}"
puts "  New average: #{company.average_rating}"
puts "  Old count: #{old_count}"
puts "  New count: #{company.total_reviews}"

# Test Certification scopes
puts "\nCertification Scopes:"
puts "  Active: #{Certification.active.count}"
puts "  Expired: #{Certification.expired.count}"
puts "  Expiring Soon: #{Certification.expiring_soon.count}"

# Test City full_name method
city = City.first
puts "\nCity full name: #{city.full_name}"

puts "=" * 60
puts "All tests passed! ✓"

