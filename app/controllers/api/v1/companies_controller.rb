# frozen_string_literal: true

module Api
  module V1
    class CompaniesController < BaseController
      before_action :set_company, only: [:show]

      # GET /api/v1/companies/search
      def search
        @companies = Company.includes(:city, :state, :country, :service_categories)

        # Apply filters
        apply_location_filters
        apply_service_filter
        apply_rating_filter
        apply_verification_filter

        # Apply sorting
        apply_sorting

        # Paginate
        @companies = @companies.page(page_params[:page]).per(page_params[:per_page])

        return render_no_results(suggestions: search_suggestions) if @companies.empty?

        # Parse includes
        includes = parse_includes(params[:include])

        # Serialize with meta and links
        options = {
          include: includes,
          params: { include_distance: @search_by_coordinates, include_meta: true },
          meta: search_meta,
          links: pagination_links(@companies, request.path)
        }

        render json: CompanySerializer.new(@companies, options).serializable_hash
      end

      # GET /api/v1/companies/:id
      def show
        includes = parse_includes(params[:include])
        set_company

        options = {
          include: includes
        }

        render json: CompanySerializer.new(@company, options).serializable_hash
      end

      private

      def set_company
        @company = Company.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_not_found('Company not found')
      end

      def apply_location_filters
        if params[:city].present?
          city = City.find_by(slug: params[:city].parameterize) ||
                 City.find_by('LOWER(name) = ?', params[:city].downcase)
          @companies = @companies.where(city_id: city.id) if city
        end

        if params[:state].present?
          state = State.find_by(slug: params[:state].parameterize) ||
                  State.find_by(code: params[:state].upcase) ||
                  State.find_by('LOWER(name) = ?', params[:state].downcase)
          if state
            city_ids = state.cities.pluck(:id)
            @companies = @companies.where(city_id: city_ids)
          end
        end

        # Geocoding search
        if params[:lat].present? && params[:lng].present?
          search_by_coordinates(params[:lat].to_f, params[:lng].to_f, params[:radius]&.to_i || 25)
        elsif params[:address].present?
          geocode_and_search(params[:address], params[:radius]&.to_i || 25)
        end
      end

      def search_by_coordinates(lat, lng, radius_miles)
        @search_by_coordinates = true
        @companies = @companies.near([lat, lng], radius_miles, units: :mi)
                               .select("companies.*, (6371 * acos(cos(radians(#{lat})) * cos(radians(latitude)) * cos(radians(longitude) - radians(#{lng})) + sin(radians(#{lat})) * sin(radians(latitude)))) AS distance_km") # rubocop:disable Layout/LineLength

        # Add distance attributes
        @companies = @companies.map do |company|
          company.define_singleton_method(:distance_miles) { (distance_km * 0.621371).round(1) }
          company.define_singleton_method(:distance_kilometers) { distance_km.round(1) }
          company
        end
      end

      def geocode_and_search(address, radius_miles)
        results = Geocoder.search(address)
        return unless results.any?

        location = results.first
        search_by_coordinates(location.latitude, location.longitude, radius_miles)
      end

      def apply_service_filter
        return if params[:service_category].blank?

        category = ServiceCategory.find_by(slug: params[:service_category])
        return unless category

        @companies = @companies.joins(:company_services)
                               .where(company_services: { service_category_id: category.id })
      end

      def apply_rating_filter
        return if params[:min_rating].blank?

        rating = params[:min_rating].to_f
        @companies = @companies.where('average_rating >= ?', rating) if rating.between?(0, 5)
      end

      def apply_verification_filter
        return unless params[:verified_only] == 'true'

        @companies = @companies.where(verified_professional: true)
      end

      def apply_sorting
        sort_param = params[:sort] || 'name'
        direction = sort_param.start_with?('-') ? 'DESC' : 'ASC'
        field = sort_param.gsub(/^-/, '')

        case field
        when 'rating'
          @companies = @companies.order("average_rating #{direction}")
        when 'name'
          @companies = @companies.order("name #{direction}")
        when 'distance'
          @companies = @companies.order("distance_km #{direction}") if @search_by_coordinates
        else
          @companies = @companies.order('name ASC')
        end
      end

      def search_meta
        {
          search_context: {
            query_type: determine_query_type,
            location: search_location_name,
            coordinates: search_coordinates,
            radius_miles: params[:radius]&.to_i || 25,
            filters_applied: {
              city: params[:city],
              state: params[:state],
              service_category: params[:service_category],
              verified_only: params[:verified_only] == 'true',
              min_rating: params[:min_rating]&.to_f
            }
          },
          pagination: pagination_meta(@companies)
        }
      end

      def determine_query_type
        return 'coordinate_search' if params[:lat].present? && params[:lng].present?
        return 'address_search' if params[:address].present?
        return 'city_search' if params[:city].present?
        return 'state_search' if params[:state].present?

        'general_search'
      end

      def search_location_name
        return "#{params[:city]}, #{params[:state]}" if params[:city] && params[:state]
        return params[:city] if params[:city]
        return params[:state] if params[:state]
        return params[:address] if params[:address]

        nil
      end

      def search_coordinates
        return { lat: params[:lat], lng: params[:lng] } if params[:lat] && params[:lng]

        nil
      end

      def search_suggestions
        suggestions = []
        suggestions << 'Try increasing the search radius' if params[:radius]
        suggestions << 'Remove some filters' if params[:min_rating] || params[:verified_only]
        suggestions << 'Try searching nearby cities'
        suggestions
      end
    end
  end
end
