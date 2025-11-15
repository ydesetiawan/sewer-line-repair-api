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
              attributes: {
                country: city.state.country.name,
                state: city.state.name,
                city: city.name,
                address: nil # TODO: Add address if needed
              }
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
              attributes: {
                country: state.country.name,
                state: state.name,
                city: nil,
                address: nil # TODO: Add address if needed
              }
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
              attributes: {
                country: country.name,
                state: nil,
                city: nil,
                address: nil # TODO: Add address if needed
              }
            }
          end
        end

        results
      end
    end
  end
end
