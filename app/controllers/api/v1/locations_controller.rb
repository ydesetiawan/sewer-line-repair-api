module Api
  module V1
    class LocationsController < BaseController
      # GET /api/v1/locations/autocomplete
      def autocomplete
        query = params[:q]

        if query.blank? || query.length < 2
          render_error('Query must be at least 2 characters', :bad_request, code: 'query_too_short')
          return
        end

        results = search_locations(query)
        limit = params[:limit].to_i.positive? ? [params[:limit].to_i, 50].min : 10

        render json: {
          data: results.first(limit),
          meta: {
            query: query,
            count: results.size,
            limit: limit
          }
        }, status: :ok, content_type: 'application/json'
      end

      # POST /api/v1/locations/geocode
      def geocode
        address = geocode_params[:address]

        if address.blank?
          render_error('Address is required', :bad_request, code: 'missing_address')
          return
        end

        coordinates = Geocoder.coordinates(address)

        if coordinates.nil?
          render_error(
            'Unable to geocode address',
            :not_found,
            code: 'geocode_failed',
            meta: { suggestions: ['Check the address format', 'Try a different address'] }
          )
          return
        end

        lat, lng = coordinates
        nearest_city = City.near([lat, lng], 50).first
        nearby_companies = Company.near([lat, lng], 25).count

        render json: {
          data: {
            type: 'geocode_result',
            attributes: {
              address: address,
              latitude: lat,
              longitude: lng,
              nearest_city: nearest_city&.name,
              nearest_state: nearest_city&.state&.name,
              nearby_companies_count: nearby_companies
            }
          }
        }, status: :ok, content_type: 'application/json'
      end

      private

      def search_locations(query)
        results = []
        type_filter = params[:type]

        # Search cities
        if type_filter.blank? || type_filter == 'city'
          cities = City.includes(:state).where('cities.name ILIKE ?', "%#{query}%").limit(10)
          results += cities.map do |city|
            {
              id: city.id,
              type: 'city',
              name: city.name,
              full_name: "#{city.name}, #{city.state.code}",
              state: city.state.name,
              state_code: city.state.code
            }
          end
        end

        # Search states
        if type_filter.blank? || type_filter == 'state'
          states = State.where('states.name ILIKE ? OR states.code ILIKE ?', "%#{query}%", "%#{query}%").limit(5)
          results += states.map do |state|
            {
              id: state.id,
              type: 'state',
              name: state.name,
              code: state.code,
              full_name: state.name
            }
          end
        end

        # Search countries
        if type_filter.blank? || type_filter == 'country'
          countries = Country.where('countries.name ILIKE ? OR countries.code ILIKE ?', "%#{query}%",
                                    "%#{query}%").limit(3)
          results += countries.map do |country|
            {
              id: country.id,
              type: 'country',
              name: country.name,
              code: country.code,
              full_name: country.name
            }
          end
        end

        results
      end

      def geocode_params
        params.permit(:address)
      end
    end
  end
end
