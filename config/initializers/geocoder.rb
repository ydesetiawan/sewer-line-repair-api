# Geocoder configuration

Geocoder.configure(
  # Geocoding options
  timeout: 3,                 # geocoding service timeout (secs)
  lookup: :nominatim,         # name of geocoding service (symbol)
  ip_lookup: :ipinfo_io,      # name of IP address geocoding service (symbol)
  language: :en,              # ISO-639 language code
  use_https: false,           # use HTTPS for lookup requests? (if supported)
  # http_proxy: nil,          # HTTP proxy server (user:pass@host:port)
  # https_proxy: nil,         # HTTPS proxy server (user:pass@host:port)
  # api_key: nil,             # API key for geocoding service
  cache: nil,                 # cache object (must respond to #[], #[]=, and #del)

  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and Timeout::Error
  # always_raise: [],

  # Calculation options
  units: :mi,                 # :km for kilometers or :mi for miles
  distances: :spherical,      # :spherical uses better distance calculation

  # PostgreSQL specific settings
  # Use quoted distance column name to avoid reserved word conflicts
  distance_column: :calculated_distance

  # Cache configuration
  # cache_options: {
  #   expiration: 2.days,
  #   prefix: 'geocoder:'
  # }
)

# For production, use a proper geocoding service like Google Maps or Mapbox
# Geocoder.configure(
#   lookup: :google,
#   api_key: ENV['GOOGLE_MAPS_API_KEY'],
#   use_https: true
# )

