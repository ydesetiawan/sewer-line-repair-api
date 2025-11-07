# Fix for Geocoder PostgreSQL syntax error with reserved word "distance"
# This patches the Geocoder gem to use a quoted column alias

module Geocoder
  module Sql
    def distance_sql(latitude, longitude, units = :mi)
      earth_radius = case units
                     when :km then 6371.0
                     when :mi then 3958.8
                     else 3958.8
                     end

      # Use quoted column name to avoid reserved word conflicts
      lat1 = latitude.to_f
      lon1 = longitude.to_f

      # Haversine formula with quoted alias
      <<-SQL
        (#{earth_radius} * 2 * ASIN(SQRT(
          POWER(SIN((#{lat1} - #{qualified_latitude_column}) * PI() / 180 / 2), 2) +
          COS(#{lat1} * PI() / 180) * COS(#{qualified_latitude_column} * PI() / 180) *
          POWER(SIN((#{lon1} - #{qualified_longitude_column}) * PI() / 180 / 2), 2)
        )))
      SQL
    end
  end
end

# Monkey patch to override the near scope
module GeocoderNearPatch
  def near(location, radius = 20, options = {})
    latitude, longitude = Geocoder::Calculations.extract_coordinates(location)

    if latitude && longitude
      distance_sql = distance_calculation(latitude, longitude)

      where("#{distance_sql} <= ?", radius)
        .select("#{table_name}.*, #{distance_sql} AS calculated_distance")
        .order("calculated_distance")
    else
      none
    end
  end

  private

  def distance_calculation(lat, lng)
    earth_radius = 3958.8 # miles

    "(#{earth_radius} * 2 * ASIN(SQRT(
      POWER(SIN((#{lat} - #{table_name}.#{geocoder_options[:latitude]}) * PI() / 180 / 2), 2) +
      COS(#{lat} * PI() / 180) * COS(#{table_name}.#{geocoder_options[:latitude]} * PI() / 180) *
      POWER(SIN((#{lng} - #{table_name}.#{geocoder_options[:longitude]}) * PI() / 180 / 2), 2)
    )))"
  end
end

