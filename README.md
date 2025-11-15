# Sewer Line Repair API

All documentation lives in the `docs/` folder for easy reference.
See [`docs/README.md`](docs/README.md) for the documentation index and full guides.

## System Requirements

* **Ruby**: 3.4.7
* **Rails**: 8.1.1
* **Database**: PostgreSQL

## Quick Setup

Install dependencies:

```bash
bundle install
```

Create and migrate the database:

```bash
bin/rails db:create db:migrate
```

Seed sample data (optional):

```bash
# Quick seed with basic data
bin/rails db:seed

# Or use custom rake tasks for comprehensive data:
bundle exec rake db:seed:us_data      # Creates 1 country, 50 states, 1000 cities
bundle exec rake db:seed:companies    # Creates 2000 companies distributed across cities
```

For detailed documentation on seeding tasks, see [`docs/RAKE_TASKS.md`](docs/RAKE_TASKS.md).

Start the server (development):

```bash
bin/rails server
```

API Base URL: `http://localhost:3000` (or your configured host/port)

## Tests

This project uses RSpec for tests. Run the test suite with:

```bash
bundle exec rspec
```

## Code Quality & Security

- Run RuboCop:

```bash
bundle exec rubocop
```

- Run Brakeman (security scan):

```bash
bundle exec brakeman
```

## Project Notes

This repository is a minimal Rails API application focused on:
- REST API endpoints (JSON:API)
- Active Record with PostgreSQL
- Active Storage for file attachments
- RSpec for testing
- Swagger (rswag) for API documentation
- RuboCop and Brakeman for code quality and security

For all developer guides, API reference, and architecture docs, see `docs/README.md`.

---

For full details, tutorials, and advanced configuration refer to the docs directory:

- `docs/README.md` — documentation index
