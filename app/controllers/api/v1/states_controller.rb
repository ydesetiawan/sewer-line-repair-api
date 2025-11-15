module Api
  module V1
    class StatesController < BaseController
      # GET /api/v1/states
      def index
        states = State
        if params['country'].present?
          country = Country.find_by('slug = ?', params['country'])
          if country
            states = states.by_country(country.id)
          else
            render_not_found_response
            return
          end
        end

        if params['state'].present?
          states = states.where('states.slug = ? OR states.name ILIKE ?', params['state'], "%#{params['state']}%")
        end

        # Use left_joins with select to count companies efficiently
        states = states.left_joins(:companies)
                       .select('states.*, COUNT(companies.id) AS companies_count')
                       .group('states.id')
                       .includes(:country)
                       .page(params[:page].presence&.to_i || 1)
                       .per(params[:per_page].presence&.to_i || 50)

        render_collection(StateSerializer, states)
      end

      # GET /api/v1/states/:state_slug/companies
      def companies
        state = State.find_by(slug: params[:state_slug])

        unless state
          render_error('State not found', :not_found, code: 'state_not_found')
          return
        end

        companies = Company.joins(:city)
                           .where(cities: { state_id: state.id })
                           .includes(:city, :state, :country, :service_categories)

        # Apply filters
        companies = filter_by_city(companies)
        companies = filter_by_service_category(companies)
        companies = filter_by_verification(companies)
        companies = filter_by_rating(companies)

        # Apply sorting
        companies = apply_sorting(companies)
        companies = companies.page(params[:page].presence&.to_i || 1)
                             .per(params[:per_page].presence&.to_i || 50)

        render_collection(
          CompanySerializer,
          companies,
          meta: {
            cities: browse_by_cities(state)
          }
        )
      end

      private

      def filter_by_city(companies)
        return companies if params[:city].blank?

        companies.where('cities.slug = ? OR cities.name ILIKE ?', params[:city], params[:city])
      end

      def filter_by_service_category(companies)
        return companies if params[:service_category].blank?

        companies.joins(:service_categories).where(
          'service_categories.slug = ? OR service_categories.name ILIKE ?',
          params[:service_category], params[:service_category]
        ).distinct
      end

      def filter_by_verification(companies)
        return companies unless params[:verified_only] == 'true'

        companies.where(verified_professional: true)
      end

      def filter_by_rating(companies)
        return companies if params[:min_rating].blank?

        min_rating = params[:min_rating].to_f
        companies.where('average_rating >= ?', min_rating) if min_rating.positive?
      end

      def apply_sorting(companies)
        sort_param = params[:sort] || 'name'

        case sort_param
        when 'rating', '-rating'
          companies.order(average_rating: sort_param.start_with?('-') ? :desc : :asc)
        when 'name', '-name'
          companies.order(name: sort_param.start_with?('-') ? :desc : :asc)
        else
          companies.order(name: :asc)
        end
      end

      def browse_by_cities(state)
        cities = City.where(state_id: state.id)
                     .left_joins(:companies)
                     .select('cities.*, COUNT(companies.id) AS companies_count')
                     .group('cities.id')
                     .includes(:state, :country)
                     .limit(32)
        {
          data: cities.map { |city| CitySerializer.new(city).serializable_hash[:data] }
        }
      end
    end
  end
end
