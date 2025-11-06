# frozen_string_literal: true

module Api
  module V1
    class StatesController < BaseController
      # GET /api/v1/states/:state_slug/companies
      def companies
        @state = State.find_by(slug: params[:state_slug]) ||
                 State.find_by(code: params[:state_slug].upcase)

        unless @state
          return render_not_found("State not found")
        end

        # Get companies in this state's cities
        city_ids = @state.cities.pluck(:id)
        @companies = Company.where(city_id: city_ids).includes(:city, :service_categories)

        # Apply filters
        if params[:city].present?
          city = @state.cities.find_by(slug: params[:city].parameterize)
          @companies = @companies.where(city_id: city.id) if city
        end

        if params[:service_category].present?
          category = ServiceCategory.find_by(slug: params[:service_category])
          if category
            @companies = @companies.joins(:company_services)
                                   .where(company_services: { service_category_id: category.id })
          end
        end

        @companies = @companies.where(verified_professional: true) if params[:verified_only] == "true"
        @companies = @companies.where("average_rating >= ?", params[:min_rating].to_f) if params[:min_rating].present?

        # Sorting
        sort_param = params[:sort] || "name"
        direction = sort_param.start_with?("-") ? "DESC" : "ASC"
        field = sort_param.gsub(/^-/, "")

        case field
        when "rating"
          @companies = @companies.order("average_rating #{direction}")
        when "name"
          @companies = @companies.order("name #{direction}")
        else
          @companies = @companies.order("name ASC")
        end

        # Paginate
        @companies = @companies.page(page_params[:page]).per(page_params[:per_page])

        # Parse includes
        includes = parse_includes(params[:include])

        options = {
          include: includes,
          meta: {
            state: {
              id: @state.id.to_s,
              name: @state.name,
              code: @state.code,
              slug: @state.slug,
              total_companies: Company.where(city_id: city_ids).count,
              total_cities: @state.cities.count
            },
            pagination: pagination_meta(@companies)
          },
          links: pagination_links(@companies, "/api/v1/states/#{@state.slug}/companies")
        }

        render json: CompanySerializer.new(@companies, options).serializable_hash
      end
    end
  end
end

