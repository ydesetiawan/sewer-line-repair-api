module Api
  module V1
    class CompaniesController < BaseController
      # GET /api/v1/companies/search
      def search
        companies = Company.includes(:city, :state, :country, :service_categories)

        # Apply filters
        companies = filter_by_location(companies)
        companies = filter_by_service_category(companies)
        companies = filter_by_verification(companies)
        companies = filter_by_rating(companies)

        # Apply sorting
        companies = apply_sorting(companies)

        # Return error if no results
        if companies.empty?
          render_error(
            'No companies found matching your criteria',
            :not_found,
            code: 'no_results',
            meta: { suggestions: ['Try increasing the search radius', 'Remove some filters'] }
          )
          return
        end

        companies = companies.page(params[:page].presence&.to_i || 1)
                             .per(params[:per_page].presence&.to_i || 2)

        render_collection(
          CompanySerializer,
          companies,
          meta: {
            cities: nil
          }
        )
      end

      # GET /api/v1/companies/:id
      def show
        company = Company.includes(
          :city, :state, :country, :reviews, :service_categories,
          :gallery_images, :certifications, :service_areas
        ).find_by(slug: params[:id])

        if company
          render_record(CompanyDetailSerializer, company)
        else
          render_error('Company not found', :not_found)
        end
      end

      private

      def filter_by_location(companies)
        # By city name
        companies = companies.joins(:city).where('cities.name ILIKE ?', params[:city]) if params[:city].present?

        # By state
        if params[:state].present?
          companies = companies.joins(:state).where(
            'states.code ILIKE ? OR states.name ILIKE ?',
            params[:state], params[:state]
          )
        end

        # By country
        if params[:country].present?
          companies = companies.joins(:country).where(
            'countries.code ILIKE ? OR countries.name ILIKE ?',
            params[:country], params[:country]
          )
        end

        # By coordinates with radius
        if params[:lat].present? && params[:lng].present?
          radius = params[:radius].to_f.positive? ? params[:radius].to_f : 25
          companies = companies.near(
            [params[:lat].to_f, params[:lng].to_f],
            radius,
            units: params[:units] == 'km' ? :km : :mi
          )
        elsif params[:address].present?
          # Geocode address and search
          coordinates = Geocoder.coordinates(params[:address])
          if coordinates
            radius = params[:radius].to_f.positive? ? params[:radius].to_f : 25
            companies = companies.near(
              coordinates,
              radius,
              units: params[:units] == 'km' ? :km : :mi
            )
          else
            render_error('Unable to geocode address', :bad_request, code: 'geocode_failed')
            return companies.none
          end
        end

        companies
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
        when 'distance', '-distance'
          # Distance sorting is handled by Geocoder's near scope
          companies
        else
          companies.order(name: :asc)
        end
      end
    end
  end
end
