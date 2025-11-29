# API: Filter Reviews by Multiple Ratings

## Overview

The Reviews API supports filtering by multiple rating values, allowing flexible querying of reviews based on customer ratings.

## Endpoint

```
GET /api/v1/companies/:company_id/reviews
```

## Query Parameters

### `ratings[]` (optional)

Filter reviews by one or more rating values.

- **Type**: Array of integers
- **Valid values**: 1, 2, 3, 4, 5
- **Default**: All ratings (if parameter is omitted)

## Usage Examples

### Filter by Single Rating

Show only 5-star reviews:
```
GET /api/v1/companies/123/reviews?ratings[]=5
```

Show only 3-star reviews:
```
GET /api/v1/companies/123/reviews?ratings[]=3
```

### Filter by Multiple Ratings

Show 1-star and 2-star reviews:
```
GET /api/v1/companies/123/reviews?ratings[]=1&ratings[]=2
```

Show 4-star and 5-star reviews:
```
GET /api/v1/companies/123/reviews?ratings[]=4&ratings[]=5
```

### Show All Ratings

Omit the `ratings[]` parameter:
```
GET /api/v1/companies/123/reviews
```

## Combining with Other Parameters

The rating filter can be combined with sorting and pagination:

```
GET /api/v1/companies/123/reviews?ratings[]=4&ratings[]=5&sort=-review_datetime_utc&page=1&per_page=20
```

## cURL Examples

### Get All Reviews

```bash
curl -X GET "http://localhost:3000/api/v1/companies/1/reviews" \
  -H "Accept: application/json"
```

### Filter by Single Rating (5-star only)

```bash
curl -X GET "http://localhost:3000/api/v1/companies/1/reviews?ratings[]=5" \
  -H "Accept: application/json"
```

### Filter by Single Rating (3-star only)

```bash
curl -X GET "http://localhost:3000/api/v1/companies/1/reviews?ratings[]=3" \
  -H "Accept: application/json"
```

### Filter by Multiple Ratings (1 and 2 stars)

```bash
curl -X GET "http://localhost:3000/api/v1/companies/1/reviews?ratings[]=1&ratings[]=2" \
  -H "Accept: application/json"
```

### Filter by Multiple Ratings (4 and 5 stars)

```bash
curl -X GET "http://localhost:3000/api/v1/companies/1/reviews?ratings[]=4&ratings[]=5" \
  -H "Accept: application/json"
```

### Filter with Sorting (5-star, newest first)

```bash
curl -X GET "http://localhost:3000/api/v1/companies/1/reviews?ratings[]=5&sort=-review_datetime_utc" \
  -H "Accept: application/json"
```

### Filter with Sorting (5-star, oldest first)

```bash
curl -X GET "http://localhost:3000/api/v1/companies/1/reviews?ratings[]=5&sort=review_datetime_utc" \
  -H "Accept: application/json"
```

### Filter with Pagination (4 and 5 stars, page 2, 10 per page)

```bash
curl -X GET "http://localhost:3000/api/v1/companies/1/reviews?ratings[]=4&ratings[]=5&page=2&per_page=10" \
  -H "Accept: application/json"
```

### Complete Example (filter + sort + pagination)

```bash
curl -X GET "http://localhost:3000/api/v1/companies/1/reviews?ratings[]=4&ratings[]=5&sort=-review_datetime_utc&page=1&per_page=20" \
  -H "Accept: application/json"
```

### Production Environment Example

```bash
curl -X GET "https://api.yourproductiondomain.com/api/v1/companies/123/reviews?ratings[]=5" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

## Response Format

```json
{
  "data": [
    {
      "id": "1",
      "type": "review",
      "attributes": {
        "review_rating": 5,
        "review_datetime_utc": "2024-01-15T10:30:00Z",
        "review_text": "Excellent service!",
        ...
      }
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 100
  }
}
```

## Validation

- Invalid rating values (outside 1-5 range) are ignored
- Non-integer values are converted to integers
- Empty arrays or all invalid values return all reviews

## Notes

- This replaces the deprecated `min_rating` parameter
- Rating values are validated server-side for security
- Multiple ratings use an OR condition (returns reviews matching any of the specified ratings)
- Replace `localhost:3000` with your actual API host and port
- Replace `company_id` with the actual company ID you want to query
- Add authentication headers if your API requires authentication
