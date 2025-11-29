# Documentation Index

All project documentation has been moved to the `docs/` folder for clarity and organization.

## 📚 Quick Navigation

### Essential Guides
- **[QUICK_START.md](QUICK_START.md)** - Start here! Quick 3-step setup
- **[INDEX.md](INDEX.md)** - Complete documentation index with categories
- **[README_MINIMAL.md](README_MINIMAL.md)** - Minimal setup guide
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Quick commands and examples

### Development
- **[DEVELOPMENT.md](DEVELOPMENT.md)** - Development workflow and best practices
- **[API_IMPLEMENTATION_COMPLETE.md](API_IMPLEMENTATION_COMPLETE.md)** - Complete API implementation guide

### Database & Seeding
- **[RAKE_TASKS.md](RAKE_TASKS.md)** - 🌱 Database seeding tasks (US data + companies)
- **[RAKE_TASKS_SUMMARY.md](RAKE_TASKS_SUMMARY.md)** - Implementation summary and stats
- **[DATABASE_SCHEMA.md](DATABASE_SCHEMA.md)** - Database structure and relationships

### API Documentation
- **[API_COMPLETE_GUIDE.md](API_COMPLETE_GUIDE.md)** - Complete API guide
- **[RSPEC_SWAGGER_COMPLETE.md](RSPEC_SWAGGER_COMPLETE.md)** - RSpec and Swagger setup
- **[CSV_IMPORT_API.md](CSV_IMPORT_API.md)** - CSV Import API documentation

### Setup & Configuration
- **[SETUP_COMPLETE.md](SETUP_COMPLETE.md)** - Complete setup guide
- **[ACTIVE_STORAGE_COMPLETE.md](ACTIVE_STORAGE_COMPLETE.md)** - Active Storage setup
- **[CORS_SETUP.md](CORS_SETUP.md)** - CORS configuration
- **[FACTORY_BOT_SETUP_COMPLETE.md](FACTORY_BOT_SETUP_COMPLETE.md)** - Factory Bot setup
- **[GEOCODING_GUIDE.md](GEOCODING_GUIDE.md)** - Geocoding implementation

### Project History
- **[UPGRADE_SUMMARY.md](UPGRADE_SUMMARY.md)** - Upgrade details (Ruby & Rails)
- **[CLEANUP_SUMMARY.md](CLEANUP_SUMMARY.md)** - What was removed and why
- **[CHECKLIST.md](CHECKLIST.md)** - Verification checklist

## 🚀 Quick Start

```bash
# 1. Install dependencies
bundle install

# 2. Setup database
bundle exec rake db:create db:migrate

# 3. Seed with realistic data
bundle exec rake db:seed:us_data      # 1 country, 50 states, 1000+ cities
bundle exec rake db:seed:companies    # 2000 companies across all cities

# 4. Start server
rails server

# 5. Visit API documentation
open http://localhost:3000/api-docs
```

## 📖 More Information

For a complete organized index with categories, see **[INDEX.md](INDEX.md)**.

Refer to each file for specific details.

