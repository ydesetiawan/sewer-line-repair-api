# Sewer Line Repair API

All documentation has been moved to the `docs/` folder for better organization.

See [`docs/README.md`](docs/README.md) for the documentation index and links to all guides.

## System Requirements

* **Ruby version**: 3.4.7
* **Rails version**: 8.1.1
* **Database**: PostgreSQL

## Setup Instructions

### 1. Install Dependencies

```bash
bundle install
```

### 2. Database Setup

Create the databases:
```bash
rails db:create
```

Run migrations:
```bash
rails db:migrate
```

Seed the database (optional):
```bash
rails db:seed
```

### 3. Start the Server

```bash
rails server
```

The API will be available at `http://localhost:3000`

## Running Tests

```bash
rails test
```

## Key Features

This is a Rails API-only application configured with:

* **PostgreSQL** database
* **Solid Cache** - Database-backed Rails cache
* **Solid Queue** - Database-backed Active Job backend
* **Solid Cable** - Database-backed Action Cable backend
* **CORS** support (commented out by default in Gemfile)
* **Kamal** - For deployment as a Docker container
* **Brakeman** - Security vulnerability scanner
* **RuboCop** - Ruby code style checker
* **Docker** support included

## API Development

### Generating a Resource

To create a new API resource (e.g., for sewer repairs):

```bash
rails generate scaffold Repair address:string status:string description:text estimated_cost:decimal --api
rails db:migrate
```

### Enabling CORS

If you need to allow cross-origin requests, uncomment this line in `Gemfile`:

```ruby
gem "rack-cors"
```

Then run `bundle install` and configure CORS in `config/initializers/cors.rb`.

## Deployment

This project includes Kamal for easy Docker-based deployment. Configuration files:

* `config/deploy.yml` - Kamal deployment configuration
* `.kamal/secrets` - Environment secrets (excluded from git)
* `Dockerfile` - Docker container configuration

Deploy with:
```bash
kamal deploy
```

## Code Quality

Run RuboCop for style checking:
```bash
bundle exec rubocop
```

Run Brakeman for security scanning:
```bash
bundle exec brakeman
```

## Additional Resources

* [Rails API Documentation](https://guides.rubyonrails.org/api_app.html)
* [Rails 8.1 Release Notes](https://guides.rubyonrails.org/8_1_release_notes.html)
* [PostgreSQL Documentation](https://www.postgresql.org/docs/)

---

## 📚 More Documentation

- **[QUICK_START.md](docs/QUICK_START.md)** - Get started in 3 steps
- **[DEVELOPMENT.md](docs/DEVELOPMENT.md)** - Development guide and best practices
- **[API_DOCUMENTATION.md](docs/API_DOCUMENTATION.md)** - API structure and examples
- **[CHECKLIST.md](docs/CHECKLIST.md)** - Setup verification checklist
- **[UPGRADE_SUMMARY.md](docs/UPGRADE_SUMMARY.md)** - Upgrade details
- **[INDEX.md](docs/INDEX.md)** - Complete documentation index
