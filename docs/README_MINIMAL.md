# Sewer Line Repair API - Minimal Setup

## Overview

A minimal Ruby on Rails 8.1.1 REST API with:
- ✅ **Rails 8.1.1** (API-only mode)
- ✅ **Ruby 3.4.7**
- ✅ **PostgreSQL** database with Active Record
- ✅ **Swagger/OpenAPI** documentation (via rswag)
- ✅ **RSpec** testing framework
- ✅ **RuboCop** code quality

## What Was Removed

This project has been cleaned up to include ONLY the essentials:

### Removed Dependencies
- ❌ Solid Cache (using memory cache instead)
- ❌ Solid Queue (using async adapter)
- ❌ Solid Cable (Action Cable removed)
- ❌ Active Storage (file uploads removed)
- ❌ Action Cable (WebSocket removed)
- ❌ Action Mailbox (inbound email removed)
- ❌ Action Text (rich text removed)
- ❌ Kamal (deployment tool removed)
- ❌ Thruster (HTTP proxy removed)
- ❌ Brakeman (security scanner removed)
- ❌ Docker files removed
- ❌ Minitest removed (using RSpec)

### What Remains
- ✅ Rails API core
- ✅ Active Record (database ORM)
- ✅ Action Controller (REST API)
- ✅ Action Mailer (email notifications)
- ✅ Active Job (background jobs)
- ✅ PostgreSQL database
- ✅ Puma web server
- ✅ Bootsnap (boot optimization)

---

## System Requirements

* **Ruby**: 3.4.7
* **Rails**: 8.1.1
* **Database**: PostgreSQL
* **Bundler**: Latest

---

## Setup Instructions

### 1. Install Dependencies

```bash
bundle install
```

### 2. Database Setup

```bash
# Create databases
rails db:create

# Run migrations (when you have them)
rails db:migrate

# Seed data (optional)
rails db:seed
```

### 3. Start the Server

```bash
rails server
```

API available at: http://localhost:3000

---

## Testing with RSpec

### Run All Tests

```bash
bundle exec rspec
```

### Run Specific Tests

```bash
# Run model tests
bundle exec rspec spec/models

# Run request tests
bundle exec rspec spec/requests

# Run specific file
bundle exec rspec spec/models/repair_spec.rb

# Run specific line
bundle exec rspec spec/models/repair_spec.rb:15
```

### Test Coverage

Tests are located in `spec/` directory:
- `spec/models/` - Model tests
- `spec/requests/` - API endpoint tests (integration)
- `spec/factories/` - FactoryBot factories
- `spec/support/` - Test helpers

---

## API Documentation with Swagger

### Access Swagger UI

Start the server and visit:
```
http://localhost:3000/api-docs
```

### Generate Swagger Documentation

```bash
# Generate swagger.yaml from RSpec tests
bundle exec rake rswag:specs:swaggerize
```

### Write Swagger Tests

Example spec file with Swagger annotations:

```ruby
# spec/requests/api/v1/repairs_spec.rb
require 'swagger_helper'

RSpec.describe 'API V1 Repairs', type: :request do
  path '/api/v1/repairs' do
    get 'Retrieves all repairs' do
      tags 'Repairs'
      produces 'application/json'

      response '200', 'repairs found' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              address: { type: :string },
              status: { type: :string }
            }
          }
        
        run_test!
      end
    end
  end
end
```

---

## Code Quality with RuboCop

### Run RuboCop

```bash
# Check all files
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a

# Auto-fix unsafe issues too
bundle exec rubocop -A

# Check specific file
bundle exec rubocop app/models/repair.rb
```

### Configuration

RuboCop configuration is in `.rubocop.yml` with:
- Rails cops enabled
- RSpec cops enabled
- Sensible defaults for API projects
- Line length: 120 characters
- Excludes generated files

---

## Creating Your First API Resource

### Example: Repairs API

```bash
# Generate model
rails generate model Repair \
  address:string \
  status:string \
  description:text \
  estimated_cost:decimal \
  scheduled_date:date \
  completed:boolean

# Run migration
rails db:migrate

# Generate controller
rails generate controller Api::V1::Repairs
```

### Controller Example

```ruby
# app/controllers/api/v1/repairs_controller.rb
class Api::V1::RepairsController < ApplicationController
  def index
    repairs = Repair.all
    render json: repairs
  end

  def show
    repair = Repair.find(params[:id])
    render json: repair
  end

  def create
    repair = Repair.new(repair_params)
    if repair.save
      render json: repair, status: :created
    else
      render json: { errors: repair.errors }, status: :unprocessable_entity
    end
  end

  private

  def repair_params
    params.require(:repair).permit(:address, :status, :description, :estimated_cost)
  end
end
```

### Routes

```ruby
# config/routes.rb
Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  
  namespace :api do
    namespace :v1 do
      resources :repairs
    end
  end
  
  get "up" => "rails/health#show", as: :rails_health_check
end
```

---

## Testing Your API

### With curl

```bash
# List repairs
curl http://localhost:3000/api/v1/repairs

# Create repair
curl -X POST http://localhost:3000/api/v1/repairs \
  -H "Content-Type: application/json" \
  -d '{
    "repair": {
      "address": "123 Main St",
      "status": "pending",
      "description": "Sewer line blockage",
      "estimated_cost": 500.00
    }
  }'

# Get repair
curl http://localhost:3000/api/v1/repairs/1

# Update repair
curl -X PUT http://localhost:3000/api/v1/repairs/1 \
  -H "Content-Type: application/json" \
  -d '{"repair": {"status": "completed"}}'

# Delete repair
curl -X DELETE http://localhost:3000/api/v1/repairs/1
```

### Health Check

```bash
curl http://localhost:3000/up
```

---

## Project Structure

```
sewer-line-repair-api/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   └── api/
│   │       └── v1/
│   │           └── repairs_controller.rb
│   ├── models/
│   │   ├── application_record.rb
│   │   └── repair.rb
│   ├── jobs/
│   └── mailers/
├── config/
│   ├── application.rb          # Rails config
│   ├── database.yml            # PostgreSQL config
│   ├── routes.rb               # API routes
│   └── initializers/
│       ├── rswag_api.rb       # Swagger API config
│       └── rswag_ui.rb        # Swagger UI config
├── db/
│   ├── migrate/                # Database migrations
│   └── seeds.rb                # Seed data
├── spec/
│   ├── models/                 # Model tests
│   ├── requests/               # API endpoint tests
│   ├── factories/              # FactoryBot factories
│   ├── support/                # Test helpers
│   ├── rails_helper.rb         # RSpec Rails config
│   ├── spec_helper.rb          # RSpec config
│   └── swagger_helper.rb       # Swagger config
├── swagger/
│   └── v1/
│       └── swagger.yaml        # Generated API docs
├── .rubocop.yml                # RuboCop config
├── .rspec                      # RSpec config
├── Gemfile                     # Dependencies
└── README.md                   # This file
```

---

## Common Commands

```bash
# Database
rails db:create              # Create database
rails db:migrate            # Run migrations
rails db:seed               # Load seed data
rails db:reset              # Drop, create, migrate, seed
rails db:rollback           # Rollback last migration

# Console
rails console               # Open Rails console
rails c                     # Short version

# Routes
rails routes                # Show all routes
rails routes | grep repairs # Filter routes

# Testing
bundle exec rspec           # Run all tests
bundle exec rspec spec/models  # Run model tests

# Code Quality
bundle exec rubocop         # Check code style
bundle exec rubocop -a      # Auto-fix issues

# Swagger
rake rswag:specs:swaggerize # Generate Swagger docs

# Server
rails server                # Start server
rails s                     # Short version
rails s -p 3001            # Use different port
```

---

## Development Workflow

1. **Create a model**
   ```bash
   rails generate model ModelName field:type
   rails db:migrate
   ```

2. **Write model tests**
   ```ruby
   # spec/models/model_name_spec.rb
   require 'rails_helper'
   
   RSpec.describe ModelName, type: :model do
     it 'is valid with valid attributes' do
       model = ModelName.new(field: 'value')
       expect(model).to be_valid
     end
   end
   ```

3. **Create controller**
   ```bash
   rails generate controller Api::V1::ModelNames
   ```

4. **Write request tests with Swagger**
   ```ruby
   # spec/requests/api/v1/model_names_spec.rb
   require 'swagger_helper'
   
   RSpec.describe 'API V1 ModelNames', type: :request do
     # ... swagger annotations
   end
   ```

5. **Run tests**
   ```bash
   bundle exec rspec
   ```

6. **Generate Swagger docs**
   ```bash
   rake rswag:specs:swaggerize
   ```

7. **Check code quality**
   ```bash
   bundle exec rubocop
   ```

---

## Environment Variables

Create a `.env` file for local development:

```bash
DATABASE_URL=postgresql://localhost/sewer_line_repair_api_development
RAILS_MAX_THREADS=5
RAILS_ENV=development
```

---

## Gems Included

### Core
- `rails` (8.1.1) - Web framework
- `pg` - PostgreSQL adapter
- `puma` - Web server
- `bootsnap` - Boot optimization

### API Documentation
- `rswag` - Swagger/OpenAPI integration
- `rswag-api` - API documentation serving
- `rswag-ui` - Swagger UI
- `rswag-specs` - RSpec integration

### Testing
- `rspec-rails` - RSpec for Rails
- `factory_bot_rails` - Test data factories
- `faker` - Fake data generation
- `database_cleaner-active_record` - Database cleanup

### Code Quality
- `rubocop` - Ruby code analyzer
- `rubocop-rails` - Rails-specific cops
- `rubocop-rspec` - RSpec-specific cops

---

## Best Practices

1. **API Versioning**: Use `/api/v1/` namespace for all endpoints
2. **RESTful Routes**: Follow REST conventions
3. **JSON Responses**: Use consistent JSON format
4. **Error Handling**: Return proper HTTP status codes
5. **Testing**: Write tests for all endpoints
6. **Documentation**: Document all endpoints with Swagger
7. **Validation**: Validate all inputs
8. **Security**: Use strong parameters
9. **Code Quality**: Run RuboCop before committing

---

## Resources

- [Rails API Guide](https://guides.rubyonrails.org/api_app.html)
- [Rails 8.1 Release Notes](https://guides.rubyonrails.org/8_1_release_notes.html)
- [RSpec Rails Documentation](https://rspec.info/documentation/)
- [Rswag Documentation](https://github.com/rswag/rswag)
- [RuboCop Documentation](https://docs.rubocop.org/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

---

## License

[Your License]

## Contributors

[Your Name]

