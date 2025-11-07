# config/initializers/geocoder.rb

config = {
  timeout: 5,
  units: :mi,
  language: :en,
  distance_column: :calculated_distance
}

if Rails.env.production?
  # Production: Use proper SSL
  config.merge!(
    lookup: :nominatim,
    use_https: true,
    http_headers: {
      "User-Agent" => "SewerLineRepairAPI/1.0 (#{ENV['CONTACT_EMAIL'] || 'your-email@example.com'})"
    },
    nominatim: {
      host: "geocode.maps.co"
    }
  )
elsif Rails.env.development?
  # Development: Disable SSL verification (temporary fix)
  config.merge!(
    lookup: :nominatim,
    use_https: true,
    http_headers: {
      "User-Agent" => "SewerLineRepairAPI/1.0 (#{ENV['CONTACT_EMAIL'] || 'your-email@example.com'})"
    },
    nominatim: {
      host: "geocode.maps.co"
    },
    # Disable SSL verification in development only
    always_raise: :all,
    ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
  )
elsif Rails.env.test?
  config.merge!(
    lookup: :test,
    ip_lookup: :test
  )
end

Geocoder.configure(config)