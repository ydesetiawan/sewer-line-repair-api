# CSV Import API - Galleries & Reviews

## Overview
This API provides endpoints to import gallery images and reviews data from CSV files. The data is imported directly into the respective tables with proper mapping to company records.

---

## API Endpoints

### 1. Import Galleries
**POST** `/api/backoffice/v1/import_galleries`

### 2. Import Reviews
**POST** `/api/backoffice/v1/import_reviews`

---

## Galleries Import

### CSV Format
The CSV file should contain the following columns:
`name`, `place_id`, `google_maps_photos.photo_url`, `google_maps_photos.photo_url_big`, `google_maps_photos.photo_date`, `google_maps_photos.photo_source_video`

### Database Schema - Table: gallery_images

| Column | Source | Description |
| :--- | :--- | :--- |
| `id` | Auto-generated | Primary key |
| `company_id` | `place_id` (CSV) | Foreign key to companies table |
| `image_url` | `google_maps_photos.photo_url` (CSV) | Standard image URL |
| `thumbnail_url` | `google_maps_photos.photo_url` (CSV) | Thumbnail image URL |
| `video_url` | `google_maps_photos.photo_source_video` (CSV) | Video URL (if available) |
| `image_datetime_utc` | `google_maps_photos.photo_date` (CSV) | Image capture date/time in UTC |
| `created_at` | Auto-generated | Record creation timestamp |
| `updated_at` | Auto-generated | Record update timestamp |

### Request Format

#### Headers
- `Content-Type`: `multipart/form-data`
- `Authorization`: `Bearer {your_token}`

#### Body
- `file`: [CSV file]

### Response Format

#### Success Response (200 OK)
```json
{
  "id": "imp_1701264622_abc123",
  "type": "import_galleries",
  "attributes": {
    "message": "Import completed successfully. 450 out of 500 rows processed successfully.",
    "summary": {
      "total_rows": 500,
      "successful": 450,
      "failed": 50,
      "galleries_created": 420,
      "galleries_updated": 30
    },
    "errors": [
      {
        "row": 15,
        "place_id": "ChIJB_EgA7NMlqcRGskKvEyEz9c",
        "company_name": "NextDoor Plumbing LLC",
        "error": {
          "code": "VALIDATION_ERROR",
          "service": "import_galleries",
          "title": "Import Error",
          "message": "Company with place_id 'ChIJB_EgA7NMlqcRGskKvEyEz9c' not found"
        }
      }
    ],
    "error_file_url": "/downloads/import_errors_galleries_20231129_143022.csv"
  }
}
```

#### Error Response (400 Bad Request)
```json
{
  "code": "INVALID_FILE_FORMAT",
  "service": "import_galleries",
  "title": "Invalid File Format",
  "message": "The uploaded file is not a valid CSV file. Please upload a CSV file with the correct format."
}
```

---

## Reviews Import

### CSV Format
The CSV file should contain the following columns:
`name`, `place_id`, `reviews_link`, `reviews_id`, `reviews_text`, `reviews_rating`, `reviews_date`, `author_title`, `author_id`, `author_image`, `review_img_urls`, `owner_answer`, `owner_answer_timestamp`, `owner_answer_timestamp_datetime_utc`, `review_link`, `review_datetime_utc`

### Database Schema - Table: reviews

| Column | Source | Description |
| :--- | :--- | :--- |
| `id` | Auto-generated | Primary key |
| `company_id` | `place_id` (CSV) | Foreign key to companies table |
| `author_title` | `author_title` (CSV) | Review author name |
| `author_image` | `author_image` (CSV) | Author profile image URL |
| `review_text` | `reviews_text` (CSV) | Review content text |
| `review_img_urls` | `review_img_urls` (CSV) | Review image URLs (JSON array) |
| `owner_answer` | `owner_answer` (CSV) | Business owner's response |
| `owner_answer_timestamp_datetime_utc` | `owner_answer_timestamp_datetime_utc` (CSV) | Owner response timestamp in UTC |
| `review_link` | `review_link` (CSV) | Direct link to review |
| `review_rating` | `review_rating` (CSV) | Rating value (1-5) |
| `review_datetime_utc` | `review_datetime_utc` (CSV) | Review date/time in UTC |
| `created_at` | Auto-generated | Record creation timestamp |
| `updated_at` | Auto-generated | Record update timestamp |

### Request Format

#### Headers
- `Content-Type`: `multipart/form-data`
- `Authorization`: `Bearer {your_token}`

#### Body
- `file`: [CSV file]

### Response Format

#### Success Response (200 OK)
```json
{
  "id": "imp_1701264622_xyz789",
  "type": "import_reviews",
  "attributes": {
    "message": "Import completed successfully. 850 out of 900 rows processed successfully.",
    "summary": {
      "total_rows": 900,
      "successful": 850,
      "failed": 50,
      "reviews_created": 800,
      "reviews_updated": 50
    },
    "errors": [
      {
        "row": 42,
        "place_id": "ChIJAbCdEf1234567890",
        "company_name": "ABC Services",
        "error": {
          "code": "VALIDATION_ERROR",
          "service": "import_reviews",
          "title": "Import Error",
          "message": "Invalid rating value. Expected 1-5, got: 6"
        }
      }
    ],
    "error_file_url": "/downloads/import_errors_reviews_20231129_143022.csv"
  }
}
```

#### Partial Success Response (200 OK - All rows failed)
```json
{
  "id": "imp_1701264622_fail123",
  "type": "import_reviews",
  "attributes": {
    "message": "Import completed with errors. 0 out of 100 rows processed successfully. Please check the error file for details.",
    "summary": {
      "total_rows": 100,
      "successful": 0,
      "failed": 100,
      "reviews_created": 0,
      "reviews_updated": 0
    },
    "errors": [...],
    "error_file_url": "/downloads/import_errors_reviews_20231129_143022.csv"
  }
}
```

#### Error Response (400 Bad Request)
```json
{
  "code": "INVALID_FILE_FORMAT",
  "service": "import_reviews",
  "title": "Invalid File Format",
  "message": "The uploaded file is not a valid CSV file. Please upload a CSV file with the correct format."
}
```

---

## Common Error Responses

### Missing File (400 Bad Request)
```json
{
  "code": "MISSING_FILE",
  "service": "import_galleries|import_reviews",
  "title": "Missing File",
  "message": "No file provided"
}
```

### File Too Large (413 Payload Too Large)
```json
{
  "code": "FILE_TOO_LARGE",
  "service": "import_galleries|import_reviews",
  "title": "File Size Exceeded",
  "message": "The uploaded file exceeds the maximum allowed size of 50MB."
}
```

### Unauthorized (401 Unauthorized)
```json
{
  "code": "UNAUTHORIZED",
  "service": "import_galleries|import_reviews",
  "title": "Authentication Required",
  "message": "Valid authentication token is required to access this endpoint."
}
```

### Internal Server Error (500 Internal Server Error)
```json
{
  "code": "INTERNAL_ERROR",
  "service": "import_galleries|import_reviews",
  "title": "Internal Server Error",
  "message": "An unexpected error occurred during import. Please try again or contact support if the problem persists."
}
```

---

## Import Process

### Galleries Import Process
1. **CSV Parsing**: Read and validate CSV file structure
2. **Company Lookup**: Find company by `place_id`
3. **Data Mapping**: Map CSV columns to database fields
4. **Upsert**: Create new gallery images or update existing ones
5. **Error Handling**: Collect and report any validation or processing errors

### Reviews Import Process
1. **CSV Parsing**: Read and validate CSV file structure
2. **Company Lookup**: Find company by `place_id`
3. **Data Validation**: Validate rating (1-5), dates, and required fields
4. **Data Mapping**: Map CSV columns to database fields
5. **Upsert**: Create new reviews or update existing ones
6. **Error Handling**: Collect and report any validation or processing errors

---

## Notes

- **File Size Limit**: Maximum 50MB per upload
- **Supported Format**: CSV files only
- **Authentication**: Bearer token required
- **Upsert Strategy**: Records are created if new, updated if they already exist
- **Company Reference**: Both imports require valid `place_id` that exists in the companies table
- **Error Reporting**: Detailed error information is provided for each failed row
- **Timestamps**: All datetime fields should be in UTC format
- **JSON Fields**: `review_img_urls` should be a valid JSON array string

---

## Sample CSV Data

### Galleries CSV Sample
```csv
name,place_id,google_maps_photos.photo_url,google_maps_photos.photo_url_big,google_maps_photos.photo_date,google_maps_photos.photo_source_video
NextDoor Plumbing LLC,ChIJB_EgA7NMlqcRGskKvEyEz9c,https://lh3.googleusercontent.com/p/AF1QipP8lcRW3kcPYKl-Xh4nbEp-NLFk7Nv6pkXuT3O2,https://lh3.googleusercontent.com/p/AF1QipP8lcRW3kcPYKl-Xh4nbEp-NLFk7Nv6pkXuT3O2=w2048-h2048-k-no,4/18/2022 0:00:00,
```

### Reviews CSV Sample
```csv
name,place_id,reviews_text,reviews_rating,author_title,author_image,review_img_urls,owner_answer,owner_answer_timestamp_datetime_utc,review_link,review_datetime_utc
NextDoor Plumbing LLC,ChIJB_EgA7NMlqcRGskKvEyEz9c,Great service!,5,John Doe,https://example.com/avatar.jpg,[],Thank you!,2023-11-29 10:00:00,https://maps.google.com/review/123,2023-11-28 15:30:00
```
