# CSV Import API - README (Updated)

## Overview
This API endpoint allows you to import company data from CSV files and distribute the data across multiple related tables (countries, states, cities, and companies) using an upsert strategy.

## API Endpoint
**POST** `/api/backoffice/v1/import_companies`

## CSV Format
The CSV file should contain the following columns:
`csvname`, `name_with_address`, `site`, `subtypes`, `phone`, `full_address`, `borough`, `street`, `city`, `postal_code`, `state`, `country`, `country_code`, `latitude`, `longitude`, `time_zone`, `rating`, `reviews`, `street_view`, `working_hours`, `about`, `logo`, `verified`, `booking_appointment_link`, `location_link`, `place_id`

## Database Schema

### Table: countries
| Column | Source | Description |
| :--- | :--- | :--- |
| `id` | Auto-generated | Primary key |
| `name` | `country` (CSV) | Country name |
| `code` | `country_code` (CSV) | Country code (e.g., "US") |
| `slug` | Generated | URL-friendly version (e.g., "united-states") |

### Table: states
| Column | Source | Description |
| :--- | :--- | :--- |
| `id` | Auto-generated | Primary key |
| `country_id` | `countries.id` | Foreign key to countries table |
| `name` | `state` (CSV) | State name |
| `code` | Generated | State code from name |
| `slug` | Generated | URL-friendly version (e.g., "las-vegas") |

### Table: cities
| Column | Source | Description |
| :--- | :--- | :--- |
| `id` | Auto-generated | Primary key |
| `state_id` | `states.id` | Foreign key to states table |
| `name` | `city` (CSV) | City name |
| `code` | Generated | City code from name |
| `slug` | Generated | URL-friendly version (e.g., "las-vegas") |
| `latitude` | NULL | Not populated from CSV |
| `longitude` | NULL | Not populated from CSV |

### Table: companies
| Column | Source | Description |
| :--- | :--- | :--- |
| `id` | `place_id` (CSV) | Primary key from Google Place ID |
| `city_id` | `cities.id` | Foreign key to cities table |
| `borough` | `borough` (CSV) | Borough/district name |
| `name` | `name` (CSV) | Company name |
| `slug` | Generated | URL-friendly version |
| `phone` | `phone` (CSV) | Phone number |
| `email` | `email` (CSV) | Email address |
| `site` | `site` (CSV) | Website URL |
| `full_address` | `full_address` (CSV) | Complete address |
| `street_address` | `street` (CSV) | Street address |
| `postal_code` | `postal_code` (CSV) | Postal/ZIP code |
| `latitude` | `latitude` (CSV) | Latitude coordinate |
| `longitude` | `longitude` (CSV) | Longitude coordinate |
| `average_rating` | `rating` (CSV) | Average rating (1-5) |
| `total_reviews` | `reviews` (CSV) | Total number of reviews |
| `verified_professional` | `verified` (CSV) | Verification status (boolean) |
| `about` | `about` (CSV) | Description/about text (JSON) |
| `subtypes` | `subtypes` (CSV) | Business subtypes |
| `working_hours` | `working_hours` (CSV) | Operating hours (JSON) |
| `logo_url` | `logo` (CSV) | Logo image URL |
| `booking_appointment_link` | `booking_appointment_link` (CSV) | Booking link |
| `location_link` | `location_link` (CSV) | Google Maps link |
| `timezone` | `time_zone` (CSV) | Timezone string |

## Request Format

### Headers
- `Content-Type`: `multipart/form-data`
- `Authorization`: `Bearer {your_token}`

### Body
- `file`: [CSV file]

## Response Format

### Success Response (200 OK)
```json
{
  "id": "imp_1701264622_abc123",
  "type": "import_companies",
  "attributes": {
    "message": "Import completed successfully. 95 out of 100 rows processed successfully.",
    "summary": {
      "total_rows": 100,
      "successful": 95,
      "failed": 5,
      "countries_created": 2,
      "countries_updated": 1,
      "states_created": 5,
      "states_updated": 2,
      "cities_created": 15,
      "cities_updated": 8,
      "companies_created": 70,
      "companies_updated": 25
    },
    "errors": [
      {
        "row": 15,
        "place_id": "ChIJB_EgA7NMlqcRGskKvEyEz9c",
        "company_name": "ABC Plumbing",
        "error": {
          "code": "VALIDATION_ERROR",
          "service": "import_companies",
          "title": "Invalid Phone Format",
          "message": "Phone number format is invalid. Expected format: +1 XXX-XXX-XXXX"
        }
      },
      {
        "row": 42,
        "place_id": "ChIJAbCdEf1234567890",
        "company_name": "XYZ Services",
        "error": {
          "code": "MISSING_FIELD",
          "service": "import_companies",
          "title": "Missing Required Field",
          "message": "Required field 'country' is missing or empty"
        }
      }
    ],
    "error_file_url": "/downloads/import_errors_20231129_143022.csv"
  }
}
```

### Partial Success Response (200 OK - All rows failed)
```json
{
  "id": "imp_1701264622_xyz789",
  "type": "import_companies",
  "attributes": {
    "message": "Import completed with errors. 0 out of 100 rows processed successfully. Please check the error file for details.",
    "summary": {
      "total_rows": 100,
      "successful": 0,
      "failed": 100,
      "countries_created": 0,
      "countries_updated": 0,
      "states_created": 0,
      "states_updated": 0,
      "cities_created": 0,
      "cities_updated": 0,
      "companies_created": 0,
      "companies_updated": 0
    },
    "errors": [...],
    "error_file_url": "/downloads/import_errors_20231129_143022.csv"
  }
}
```

### Error Response (400 Bad Request)
```json
{
  "code": "INVALID_FILE_FORMAT",
  "service": "import_companies",
  "title": "Invalid File Format",
  "message": "The uploaded file is not a valid CSV file. Please upload a CSV file with the correct format."
}
```

### Error Response (413 Payload Too Large)
```json
{
  "code": "FILE_TOO_LARGE",
  "service": "import_companies",
  "title": "File Size Exceeded",
  "message": "The uploaded file exceeds the maximum allowed size of 50MB."
}
```

### Error Response (401 Unauthorized)
```json
{
  "code": "UNAUTHORIZED",
  "service": "import_companies",
  "title": "Authentication Required",
  "message": "Valid authentication token is required to access this endpoint."
}
```

### Error Response (500 Internal Server Error)
```json
{
  "code": "INTERNAL_ERROR",
  "service": "import_companies",
  "title": "Internal Server Error",
  "message": "An unexpected error occurred during import. Please try again or contact support if the problem persists."
}
```
