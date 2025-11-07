# frozen_string_literal: true

module Api
  module V1
    class LocationsController < BaseController
      # GET /api/v1/locations/autocomplete
      def autocomplete
        query = params[:q]
        limit = [params[:limit].to_i, 10].min
        limit = 10 if limit < 1

        if query.blank? || query.length < 2
          return render_jsonapi_error(
            status: 400,
            code: 'invalid_parameter',
            title: 'Invalid Parameter',
            detail: 'Query must be at least 2 characters',
            source: { parameter: 'q' }
          )
        end

        results = case params[:type]
                  when 'city'
                    search_cities(query, limit)
                  when 'state'
                    search_states(query, limit)
                  when 'country'
                    search_countries(query, limit)
                  else
                    # Search all types
                    search_cities(query, limit / 2) + search_states(query, limit / 2)
                  end

        # Get included states/countries
        included_states = []
        included_countries = []

        results.each do |result|
          if result.is_a?(City)
            included_states << result.state unless included_states.include?(result.state)
            included_countries << result.state.country unless included_countries.include?(result.state.country)
          elsif result.is_a?(State)
            included_countries << result.country unless included_countries.include?(result.country)
          end
        end

        options = {
          include: %i[state country],
          params: { include_counts: true, include_full_name: true },
          meta: {
            query: query,
            total_results: results.count
          }
        }

        # Serialize based on type
        serialized = results.map do |result|
          case result
          when City
            CitySerializer.new(result, params: options[:params]).serializable_hash[:data]
          when State
            StateSerializer.new(result, params: options[:params]).serializable_hash[:data]
          when Country
            CountrySerializer.new(result, params: options[:params]).serializable_hash[:data]
          end
        end

        # Build included
        included = []
        included += included_states.map { |s| StateSerializer.new(s).serializable_hash[:data] }
        included += included_countries.map { |c| CountrySerializer.new(c).serializable_hash[:data] }

        render json: {
          data: serialized,
          included: included,
          meta: options[:meta]
        }
      end

      # POST /api/v1/locations/geocode
      def geocode
        address = params.dig(:data, :attributes, :address)

        if address.blank?
          return render_jsonapi_error(
            status: 422,
            code: 'validation_error',
            title: 'Validation Error',
            detail: 'Address is required',
            source: { pointer: '/data/attributes/address' }
          )
        end

        results = Geocoder.search(address)

        if results.empty?
          return render_jsonapi_error(
            status: 422,
            code: 'geocoding_failed',
            title: 'Geocoding Failed',
            detail: 'Unable to geocode the provided address',
            source: { pointer: '/data/attributes/address' },
            meta: {
              suggestions: [
                'Check address format',
                'Include city and state',
                'Try a more specific address'
              ]
            }
          )
        end

        location = results.first

        # Try to match to a city in our database
        city = City.near([location.latitude, location.longitude], 50, units: :mi).first

        response_data = {
          id: 'temp-geocode-result',
          type: 'geocode_result',
          attributes: {
            formatted_address: location.formatted_address,
            street_address: location.street_address || location.address,
            zip_code: location.postal_code,
            latitude: location.latitude.to_s,
            longitude: location.longitude.to_s
          }
        }

        if city
          response_data[:relationships] = {
            city: { data: { id: city.id.to_s, type: 'city' } },
            state: { data: { id: city.state.id.to_s, type: 'state' } },
            country: { data: { id: city.state.country.id.to_s, type: 'country' } }
          }
          response_data[:meta] = {
            nearby_companies_count: city.companies.count
          }

          included = [
            CitySerializer.new(city).serializable_hash[:data],
            StateSerializer.new(city.state).serializable_hash[:data],
            CountrySerializer.new(city.state.country).serializable_hash[:data]
          ]

          render json: { data: response_data, included: included }
        else
          render json: { data: response_data }
        end
      end

      private

      def search_cities(query, limit)
        City.where('LOWER(name) LIKE ?', "%#{query.downcase}%")
            .includes(:state, :country)
            .limit(limit)
      end

      def search_states(query, limit)
        State.where('LOWER(name) LIKE ? OR LOWER(code) LIKE ?', "%#{query.downcase}%", "%#{query.downcase}%")
             .includes(:country)
             .limit(limit)
      end

      def search_countries(query, limit)
        Country.where('LOWER(name) LIKE ? OR LOWER(code) LIKE ?', "%#{query.downcase}%", "%#{query.downcase}%")
               .limit(limit)
      end
    end
  end
end
