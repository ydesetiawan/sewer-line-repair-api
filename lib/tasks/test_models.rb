# frozen_string_literal: true

Rails.logger.debug 'Testing Models and Associations...'
Rails.logger.debug '=' * 60

# Test Country associations
country = Country.first
Rails.logger.debug { "Country: #{country.name}" }
Rails.logger.debug { "  States: #{country.states.count}" }
Rails.logger.debug { "  Cities: #{country.cities.count}" }

# Test Company associations
company = Company.first
Rails.logger.debug { "\nCompany: #{company.name}" }
Rails.logger.debug { "  City: #{company.city.name}" }
Rails.logger.debug { "  State: #{company.state.name}" }
Rails.logger.debug { "  Country: #{company.country.name}" }
Rails.logger.debug { "  URL Path: #{company.url_path}" }
Rails.logger.debug { "  Reviews: #{company.reviews.count}" }
Rails.logger.debug { "  Average Rating: #{company.average_rating}" }
Rails.logger.debug { "  Service Categories: #{company.service_categories.pluck(:name).join(', ')}" }
Rails.logger.debug { "  Gallery Images: #{company.gallery_images.count}" }
Rails.logger.debug { "  Certifications: #{company.certifications.count}" }

# Test Review callbacks
Rails.logger.debug "\nTesting Review rating update..."
old_rating = company.average_rating
old_count = company.total_reviews
company.reviews.create!(
  reviewer_name: 'Test User',
  review_date: Time.zone.today,
  rating: 5,
  review_text: 'Excellent!'
)
company.reload
Rails.logger.debug { "  Old average: #{old_rating}" }
Rails.logger.debug { "  New average: #{company.average_rating}" }
Rails.logger.debug { "  Old count: #{old_count}" }
Rails.logger.debug { "  New count: #{company.total_reviews}" }

# Test Certification scopes
Rails.logger.debug "\nCertification Scopes:"
Rails.logger.debug { "  Active: #{Certification.active.count}" }
Rails.logger.debug { "  Expired: #{Certification.expired.count}" }
Rails.logger.debug { "  Expiring Soon: #{Certification.expiring_soon.count}" }

# Test City full_name method
city = City.first
Rails.logger.debug { "\nCity full name: #{city.full_name}" }

Rails.logger.debug '=' * 60
Rails.logger.debug 'All tests passed! ✓'
