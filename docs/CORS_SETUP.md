# CORS Configuration

## Overview

This API uses `rack-cors` middleware to handle Cross-Origin Resource Sharing (CORS) requests, allowing the API to be accessed from web browsers running on different domains.

## Configuration

The CORS configuration is located in `config/initializers/cors.rb`.

### Development Environment

In development and test environments, **all origins are allowed** by default. This makes local development easier and allows you to test from any local port or domain.

```ruby
# Allows requests from:
# - http://localhost:3000
# - http://localhost:8080
# - http://127.0.0.1:3000
# - Any other origin
```

### Production Environment

In production, CORS is configured to only allow specific origins for security. You must set the `ALLOWED_ORIGINS` environment variable with a comma-separated list of allowed domains.

#### Setting Allowed Origins

**Example 1: Single domain**
```bash
ALLOWED_ORIGINS="https://example.com"
```

**Example 2: Multiple domains**
```bash
ALLOWED_ORIGINS="https://example.com,https://www.example.com,https://app.example.com"
```

**Example 3: Allow all (not recommended for production)**
```bash
ALLOWED_ORIGINS="*"
```

### Allowed Methods

The following HTTP methods are allowed:
- `GET`
- `POST`
- `PUT`
- `PATCH`
- `DELETE`
- `OPTIONS` (for preflight requests)
- `HEAD`

### Exposed Headers

The following response headers are exposed to the browser:
- `Authorization`
- `Content-Type`
- `X-Total-Count`
- `X-Total-Pages`
- `X-Per-Page`
- `X-Page`

These headers are used for pagination and authentication.

### Max Age

Preflight requests are cached for 600 seconds (10 minutes) to reduce the number of OPTIONS requests.

## Testing CORS

### Using cURL

Test CORS preflight request:
```bash
curl -I -X OPTIONS http://localhost:3000/api/v1/companies/search \
  -H "Origin: http://localhost:8080" \
  -H "Access-Control-Request-Method: GET"
```

Test CORS on actual request:
```bash
curl -I http://localhost:3000/api/v1/companies/search \
  -H "Origin: http://localhost:8080"
```

You should see these headers in the response:
```
access-control-allow-origin: *
access-control-allow-methods: GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD
access-control-expose-headers: Authorization, Content-Type, X-Total-Count, X-Total-Pages, X-Per-Page, X-Page
access-control-max-age: 600
```

### Using Browser DevTools

1. Open your browser's Developer Tools (F12)
2. Go to the Network tab
3. Make a request to the API from your frontend
4. Check the response headers for `Access-Control-*` headers

## Common Issues

### Issue: "CORS policy: No 'Access-Control-Allow-Origin' header"

**Solution**: Make sure the Rails server has been restarted after updating the CORS configuration.

```bash
# Stop the server
lsof -ti:3000 | xargs kill -9

# Start the server
rails s
```

### Issue: "CORS policy: The value of the 'Access-Control-Allow-Origin' header in the response must not be the wildcard '*'"

**Solution**: In production, set specific origins in the `ALLOWED_ORIGINS` environment variable instead of using `*`.

### Issue: "CORS policy: Method [METHOD] is not allowed"

**Solution**: Check that the HTTP method you're trying to use is included in the `methods` array in `cors.rb`.

## Security Considerations

1. **Never use `origins '*'` in production** - Always specify exact domains
2. **Use HTTPS in production** - Set `ALLOWED_ORIGINS` with `https://` URLs only
3. **Limit exposed headers** - Only expose headers that your frontend actually needs
4. **Review allowed methods** - Only allow HTTP methods that your API actually uses

## Deployment

When deploying to production, ensure you set the `ALLOWED_ORIGINS` environment variable:

### Heroku
```bash
heroku config:set ALLOWED_ORIGINS="https://example.com,https://www.example.com"
```

### Docker
```bash
docker run -e ALLOWED_ORIGINS="https://example.com" your-image
```

### AWS/DigitalOcean/etc.
Add the environment variable through your hosting provider's dashboard or configuration file.

## References

- [rack-cors GitHub Repository](https://github.com/cyu/rack-cors)
- [MDN CORS Documentation](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [Rails Guide: Configuring Rails Applications](https://guides.rubyonrails.org/configuring.html)

