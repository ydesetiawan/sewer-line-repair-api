# 🚀 Quick Reference Card

## Rails 8.1.1 + Ruby 3.4.7 Minimal API Setup

---

## ✅ What's Included

| Component | Purpose |
|-----------|---------|
| **Rails 8.1.1** | API framework |
| **Ruby 3.4.7** | Programming language |
| **PostgreSQL** | Database |
| **Active Record** | ORM |
| **RSpec** | Testing |
| **Swagger (rswag)** | API documentation |
| **RuboCop** | Code quality |
| **FactoryBot** | Test factories |
| **Faker** | Fake data |

---

## 📦 Gem Count

- **Production**: 8 gems
- **Development/Test**: 7 gems
- **Total**: ~92 gems (minimal)

---

## 🎯 Essential Commands

### Setup
```bash
bundle install              # Install dependencies
rails db:create            # Create database
rails db:migrate           # Run migrations
rails server               # Start server (port 3000)
```

### Testing
```bash
bundle exec rspec          # Run all tests
bundle exec rspec spec/models     # Run model tests
bundle exec rspec spec/requests   # Run API tests
```

### Code Quality
```bash
bundle exec rubocop        # Check code style
bundle exec rubocop -a     # Auto-fix issues
```

### API Documentation
```bash
rake rswag:specs:swaggerize   # Generate Swagger docs
# Visit: http://localhost:3000/api-docs
```

### Database
```bash
rails db:create            # Create database
rails db:migrate          # Run migrations
rails db:rollback         # Rollback migration
rails db:reset            # Drop, create, migrate
rails db:seed             # Load seed data
```

### Generate Code
```bash
# Model
rails g model Repair address:string status:string

# Controller
rails g controller Api::V1::Repairs

# Migration
rails g migration AddFieldToRepairs field:type
```

### Console
```bash
rails console             # Interactive console
rails c                   # Short version
```

### Routes
```bash
rails routes              # Show all routes
rails routes | grep repairs  # Filter routes
```

---

## 🏗️ Project Structure

```
app/
├── controllers/          # REST API controllers
│   └── api/v1/          # Versioned API
├── models/              # Active Record models
├── jobs/                # Background jobs
└── mailers/             # Email templates

config/
├── application.rb       # Rails config (minimized)
├── database.yml         # PostgreSQL config (single DB)
├── routes.rb            # API routes
└── initializers/
    ├── rswag_api.rb    # Swagger API
    └── rswag_ui.rb     # Swagger UI

spec/
├── models/              # Model tests
├── requests/            # API endpoint tests
├── factories/           # FactoryBot factories
├── rails_helper.rb      # RSpec Rails config
└── swagger_helper.rb    # Swagger config

swagger/
└── v1/
    └── swagger.yaml     # Generated API docs
```

---

## 📝 Example API Resource

### 1. Generate Model
```bash
rails g model Repair address:string status:string description:text
rails db:migrate
```

### 2. Create Factory
```ruby
# spec/factories/repairs.rb
FactoryBot.define do
  factory :repair do
    address { Faker::Address.full_address }
    status { "pending" }
    description { Faker::Lorem.sentence }
  end
end
```

### 3. Write Model Test
```ruby
# spec/models/repair_spec.rb
require 'rails_helper'

RSpec.describe Repair, type: :model do
  it "is valid with valid attributes" do
    repair = build(:repair)
    expect(repair).to be_valid
  end
end
```

### 4. Create Controller
```ruby
# app/controllers/api/v1/repairs_controller.rb
class Api::V1::RepairsController < ApplicationController
  def index
    repairs = Repair.all
    render json: repairs
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
    params.require(:repair).permit(:address, :status, :description)
  end
end
```

### 5. Add Routes
```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :repairs, only: [:index, :create, :show, :update, :destroy]
  end
end
```

### 6. Write Request Test with Swagger
```ruby
# spec/requests/api/v1/repairs_spec.rb
require 'swagger_helper'

RSpec.describe 'API V1 Repairs', type: :request do
  path '/api/v1/repairs' do
    get 'Retrieves repairs' do
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
    
    post 'Creates a repair' do
      tags 'Repairs'
      consumes 'application/json'
      parameter name: :repair, in: :body, schema: {
        type: :object,
        properties: {
          address: { type: :string },
          status: { type: :string },
          description: { type: :string }
        },
        required: ['address']
      }
      
      response '201', 'repair created' do
        let(:repair) { { repair: { address: '123 Main St', status: 'pending' } } }
        run_test!
      end
    end
  end
end
```

### 7. Run Tests & Generate Docs
```bash
bundle exec rspec
rake rswag:specs:swaggerize
```

### 8. Test API
```bash
# Create
curl -X POST http://localhost:3000/api/v1/repairs \
  -H "Content-Type: application/json" \
  -d '{"repair":{"address":"123 Main St","status":"pending"}}'

# List
curl http://localhost:3000/api/v1/repairs
```

---

## 🔧 Configuration Files

| File | Purpose |
|------|---------|
| `.ruby-version` | Ruby 3.4.7 |
| `Gemfile` | Dependencies (minimal) |
| `.rspec` | RSpec options |
| `.rubocop.yml` | Code style rules |
| `spec/swagger_helper.rb` | API documentation |
| `config/database.yml` | PostgreSQL (single DB) |
| `config/application.rb` | Rails (minimal railtie) |

---

## 🚫 What Was Removed

- ❌ Solid Cache/Queue/Cable
- ❌ Active Storage
- ❌ Action Cable/Mailbox/Text
- ❌ Kamal deployment
- ❌ Docker files
- ❌ Minitest
- ❌ Brakeman
- ❌ Multiple databases

---

## 🌐 Endpoints

| Endpoint | Purpose |
|----------|---------|
| `GET /up` | Health check |
| `GET /api-docs` | Swagger UI |
| `GET /api/v1/*` | Your API routes |

---

## 📚 Documentation

| File | Description |
|------|-------------|
| `README_MINIMAL.md` | Complete setup guide ⭐ |
| `CLEANUP_SUMMARY.md` | What was removed |
| `QUICK_REFERENCE.md` | This file |

---

## 💡 Tips

1. **Open new terminal** after Ruby version change
2. **Use `bundle exec`** for all commands
3. **Version your API** with `/api/v1/`
4. **Write tests first** (TDD)
5. **Document with Swagger** in request specs
6. **Run RuboCop** before committing
7. **Check health** at `/up` endpoint

---

## 🆘 Troubleshooting

| Problem | Solution |
|---------|----------|
| Ruby version wrong | Open new terminal, run `ruby --version` |
| Gems not found | Run `bundle install` |
| Database error | Check PostgreSQL is running |
| Tests failing | Run `rails db:test:prepare` |
| Server won't start | Check for syntax errors with RuboCop |

---

## ⚡ Super Quick Start

```bash
# 1. Setup
bundle install
rails db:create

# 2. Create resource
rails g model Repair address:string status:string
rails db:migrate

# 3. Test
bundle exec rspec

# 4. Start
rails server

# 5. Visit Swagger
open http://localhost:3000/api-docs
```

---

**Status:** ✅ Ready for REST API development!  
**Stack:** Rails 8.1.1 + Ruby 3.4.7 + PostgreSQL + RSpec + Swagger + RuboCop

