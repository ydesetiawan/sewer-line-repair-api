# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # In development/test: allow all origins
    # In production: set ALLOWED_ORIGINS environment variable with comma-separated domains
    # Example: ALLOWED_ORIGINS="https://example.com,https://www.example.com"
    if Rails.env.production?
      origins ENV.fetch('ALLOWED_ORIGINS', '').split(',').map(&:strip)
    else
      origins '*'
    end

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization', 'Content-Type', 'X-Total-Count', 'X-Total-Pages', 'X-Per-Page', 'X-Page'],
      max_age: 600
  end
end

