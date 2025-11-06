source "https://rubygems.org"

# Rails API framework
gem "rails", "~> 8.1.1"

# PostgreSQL database
gem "pg", "~> 1.1"

# Puma web server
gem "puma", ">= 5.0"

# Boot optimization
gem "bootsnap", require: false

# Windows timezone data
gem "tzinfo-data", platforms: %i[ windows jruby ]

# API Documentation with Swagger
gem "rswag"
gem "rswag-api"
gem "rswag-ui"
gem "ostruct"

group :development, :test do
  # RSpec testing framework
  gem "rspec-rails", "~> 7.1"
  gem "rswag-specs"

  # Test helpers
  gem "factory_bot_rails"
  gem "faker"
  gem "database_cleaner-active_record"

  # Code quality
  gem "rubocop", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rails", require: false

  # Security scanning
  gem "brakeman", require: false
end

group :development do
  # Development tools
  gem "listen"
end


