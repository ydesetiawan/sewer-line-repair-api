# frozen_string_literal: true

module Api
  module V1
    class ReviewsController < BaseController
      before_action :set_company

      # GET /api/v1/companies/:company_id/reviews
      def index
        @reviews = @company.reviews

        # Apply filters
        @reviews = @reviews.verified if params[:verified_only] == "true"
        @reviews = @reviews.where("rating >= ?", params[:min_rating].to_i) if params[:min_rating].present?

        # Apply sorting
        sort_param = params[:sort] || "-review_date"
        direction = sort_param.start_with?("-") ? "DESC" : "ASC"
        field = sort_param.gsub(/^-/, "")

        case field
        when "review_date"
          @reviews = @reviews.order("review_date #{direction}")
        when "rating"
          @reviews = @reviews.order("rating #{direction}")
        else
          @reviews = @reviews.order("review_date DESC")
        end

        # Paginate
        @reviews = @reviews.page(page_params[:page]).per(page_params[:per_page])

        # Calculate rating distribution
        rating_dist = @company.reviews.group(:rating).count
        rating_distribution = (1..5).to_h { |r| [r, rating_dist[r] || 0] }

        options = {
          meta: {
            pagination: pagination_meta(@reviews),
            rating_distribution: rating_distribution
          },
          links: pagination_links(@reviews, "/api/v1/companies/#{@company.id}/reviews")
        }

        render json: ReviewSerializer.new(@reviews, options).serializable_hash
      end

      private

      def set_company
        @company = Company.find(params[:company_id])
      rescue ActiveRecord::RecordNotFound
        render_not_found("Company not found")
      end
    end
  end
end

