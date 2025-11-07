module Api
  module V1
    class StatesController < BaseController
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

        render_jsonapi_collection(
          companies,
          meta: {
            state: {
              id: state.id,
              name: state.name,
              code: state.code,
              slug: state.slug
            }
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
    end
  end
end
