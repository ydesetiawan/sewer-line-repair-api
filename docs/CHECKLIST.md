# Project Setup Verification Checklist

Use this checklist to verify your Rails 8.1.1 + Ruby 3.4.7 setup is complete.

## ✅ Version Verification

Run these commands to verify versions:

```bash
# Ruby version (should be 3.4.7)
ruby --version

# Rails version (should be 8.1.1)
bundle exec rails --version

# Bundler version
bundle --version

# PostgreSQL connection
psql --version
```

## ✅ File Verification

Check that these files have been updated:

- [ ] `.ruby-version` contains `3.4.7`
- [ ] `Gemfile` contains `gem "rails", "~> 8.1.1"`
- [ ] `Gemfile.lock` shows `rails (8.1.1)`
- [ ] `README.md` shows correct versions

## ✅ Database Verification

```bash
# Database should exist
rails db:migrate:status

# Should show:
# database: sewer_line_repair_api_development
```

## ✅ Server Verification

```bash
# Start the server
rails server

# In another terminal, test the health check
curl http://localhost:3000/up

# Should return: HTTP 200 OK
```

## ✅ Dependencies Verification

```bash
# Check all gems are installed
bundle check

# Should show: "The Gemfile's dependencies are satisfied"
```

## ✅ Code Quality Tools

```bash
# RuboCop (should run without errors)
bundle exec rubocop --version

# Brakeman (should run without errors)
bundle exec brakeman --version
```

## ✅ Development Tools

```bash
# Rails console
rails console
# Type: Rails.version
# Should output: "8.1.1"
# Type: exit

# Rails routes
rails routes
# Should show the /up health check route

# Generate a test model (optional)
rails generate model TestModel name:string
rails db:migrate
rails destroy model TestModel
rails db:rollback
```

## 📚 Documentation Files

Verify these documentation files exist:

- [ ] `README.md` - Project overview
- [ ] `DEVELOPMENT.md` - Development guide
- [ ] `API_DOCUMENTATION.md` - API structure
- [ ] `UPGRADE_SUMMARY.md` - Upgrade details
- [ ] `CHECKLIST.md` - This file

## 🎯 Next Steps

Once all items are checked:

1. **Start developing your API**
   ```bash
   # Example: Generate a repair resource
   rails generate scaffold Repair address:string status:string description:text estimated_cost:decimal --api
   rails db:migrate
   ```

2. **Enable CORS if needed**
   - Uncomment `gem "rack-cors"` in Gemfile
   - Run `bundle install`
   - Configure `config/initializers/cors.rb`

3. **Add authentication**
   - Consider JWT tokens
   - Add devise-api or similar

4. **Set up testing**
   - Write tests in `test/` directory
   - Run with `rails test`

5. **Version your API**
   - Create `app/controllers/api/v1/` structure
   - Update routes to namespace under `/api/v1/`

## 🚨 Troubleshooting

### Ruby version not switching

```bash
# Reload rbenv
rbenv rehash

# Check rbenv versions
rbenv versions

# Check which Ruby
which ruby

# Should show: ~/.rbenv/shims/ruby
```

### Bundle issues

```bash
# Re-install dependencies
bundle install

# Update specific gem
bundle update <gem_name>

# Clean and reinstall
rm -rf vendor/bundle
bundle install
```

### Database connection issues

```bash
# Check PostgreSQL is running
brew services list | grep postgresql

# Start PostgreSQL if needed
brew services start postgresql

# Recreate databases
rails db:drop db:create db:migrate
```

## ✨ Success!

If all checks pass, your Ruby on Rails 8.1.1 API with Ruby 3.4.7 is ready for development!

---

**Last Updated**: November 6, 2025
**Ruby Version**: 3.4.7
**Rails Version**: 8.1.1

