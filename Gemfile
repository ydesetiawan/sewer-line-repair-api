source 'https://rubygems.org'

# Rails API framework
gem 'rails', '~> 8.1.1'
gem 'rails', '~> 8.1.1', require: %w[
  active_record/railtie
  action_controller/railtie
  action_view/railtie
  action_mailer/railtie
  active_job/railtie
  action_cable/railtie
  rails/test_unit/railtie
]

# PostgreSQL database
gem 'pg', '~> 1.1'

# Puma web server
gem 'puma', '>= 5.0'

# Boot optimization
gem 'bootsnap', require: false

# Windows timezone data
gem 'tzinfo-data', platforms: %i[windows jruby]

# API Documentation with Swagger
gem 'ostruct'
gem 'rswag'
gem 'rswag-api'
gem 'rswag-ui'

# JSON:API serialization
gem 'jsonapi-serializer'

# Pagination
gem 'kaminari'

# Geocoding
gem 'geocoder'

# CORS support
gem 'rack-cors'

group :development, :test do
  # RSpec testing framework
  gem 'rspec-rails', '~> 7.1'
  gem 'rswag-specs'

  # Test helpers
  gem 'database_cleaner-active_record'
  gem 'factory_bot_rails'
  gem 'faker'

  # Code quality
  gem 'rubocop', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false

  # Security scanning
  gem 'brakeman', require: false
end

group :development do
  # Development tools
  gem 'listen'
end
