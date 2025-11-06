# Development Guide

## Quick Start

1. **Install dependencies**
   ```bash
   bundle install
   ```

2. **Setup database**
   ```bash
   rails db:create
   rails db:migrate
   ```

3. **Start the server**
   ```bash
   rails server
   # or
   bin/dev
   ```

4. **Check API health**
   ```bash
   curl http://localhost:3000/up
   ```

## Common Development Tasks

### Generate a New Model

```bash
rails generate model User name:string email:string
rails db:migrate
```

### Generate an API Endpoint

```bash
rails generate scaffold_controller api/v1/Users
```

### Generate a Full Resource

```bash
rails generate scaffold Repair address:string status:string description:text estimated_cost:decimal --api
rails db:migrate
```

### Database Operations

```bash
# Create database
rails db:create

# Run migrations
rails db:migrate

# Rollback last migration
rails db:rollback

# Reset database (drop, create, migrate)
rails db:reset

# Seed database
rails db:seed

# View database status
rails db:migrate:status
```

### Console

```bash
# Start Rails console
rails console
# or
rails c

# Start console in sandbox mode (rollback changes on exit)
rails console --sandbox
```

### Testing

```bash
# Run all tests
rails test

# Run specific test file
rails test test/models/user_test.rb

# Run specific test
rails test test/models/user_test.rb:10
```

### Code Quality

```bash
# Run RuboCop (style checking)
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a

# Run Brakeman (security scanning)
bundle exec brakeman
```

### Routes

```bash
# List all routes
rails routes

# Search for specific routes
rails routes | grep users
```

## API Structure

This is an API-only Rails application. Recommended structure:

```
app/
├── controllers/
│   ├── application_controller.rb
│   └── api/
│       └── v1/
│           ├── base_controller.rb
│           └── users_controller.rb
├── models/
│   └── user.rb
└── serializers/  # (optional, add gem)
    └── user_serializer.rb
```

## Environment Variables

Create a `.env` file for local development:

```bash
DATABASE_URL=postgresql://localhost/sewer_line_repair_api_development
RAILS_MAX_THREADS=5
```

## Useful Gems to Consider

### Authentication
- `devise` - User authentication
- `devise-api` - API authentication with Devise
- `jwt` - JSON Web Tokens

### Serialization
- `jsonapi-serializer` - Fast JSON:API serialization
- `active_model_serializers` - ActiveModel::Serializer

### Documentation
- `rswag` - Swagger/OpenAPI documentation
- `apipie-rails` - API documentation

### Authorization
- `pundit` - Authorization policies
- `cancancan` - Authorization

### Pagination
- `kaminari` - Pagination
- `pagy` - Fast pagination

### CORS
Uncomment in Gemfile:
```ruby
gem "rack-cors"
```

Then configure in `config/initializers/cors.rb`

## Docker Development

Build the Docker image:
```bash
docker build -t sewer-line-repair-api .
```

Run with Docker Compose (create docker-compose.yml first):
```bash
docker-compose up
```

## Debugging

Add breakpoints in your code:
```ruby
debugger
```

Then run your server or tests to hit the breakpoint.

## Performance Monitoring

Check slow queries:
```ruby
# Add to config/environments/development.rb
config.active_record.verbose_query_logs = true
```

## Best Practices

1. **Versioning**: Version your API endpoints (e.g., `/api/v1/`)
2. **Serialization**: Use serializers to control JSON output
3. **Error Handling**: Implement consistent error responses
4. **Authentication**: Add JWT or token-based auth
5. **Rate Limiting**: Consider adding rate limiting
6. **Documentation**: Document your API endpoints
7. **Testing**: Write tests for all endpoints
8. **Pagination**: Implement pagination for list endpoints
9. **Validation**: Validate all inputs
10. **Security**: Use strong parameters and CORS appropriately

## Resources

- [Rails API Guide](https://guides.rubyonrails.org/api_app.html)
- [Rails 8.1 Release Notes](https://guides.rubyonrails.org/8_1_release_notes.html)
- [Rails Routing](https://guides.rubyonrails.org/routing.html)
- [Active Record Basics](https://guides.rubyonrails.org/active_record_basics.html)
- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)

