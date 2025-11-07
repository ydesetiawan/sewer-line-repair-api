module Api
  module V1
    class ReviewsController < BaseController
      before_action :set_company

      # GET /api/v1/companies/:company_id/reviews
      def index
        reviews = @company.reviews

        # Apply filters
        reviews = filter_by_verification(reviews)
        reviews = filter_by_rating(reviews)

        # Apply sorting
        reviews = apply_sorting(reviews)

        # Calculate rating distribution
        rating_distribution = calculate_rating_distribution(@company.reviews)

        render_jsonapi_collection(
          reviews,
          meta: { rating_distribution: rating_distribution }
        )
      end

      private

      def set_company
        @company = Company.find_by(id: params[:company_id])
        render_error('Company not found', :not_found) unless @company
      end

      def filter_by_verification(reviews)
        return reviews unless params[:verified_only] == 'true'

        reviews.where(verified_review: true)
      end

      def filter_by_rating(reviews)
        return reviews if params[:min_rating].blank?

        min_rating = params[:min_rating].to_f
        reviews.where('rating >= ?', min_rating) if min_rating.positive?
      end

      def apply_sorting(reviews)
        sort_param = params[:sort] || '-review_date'

        case sort_param
        when 'rating', '-rating'
          reviews.order(rating: sort_param.start_with?('-') ? :desc : :asc)
        when 'review_date', '-review_date'
          reviews.order(review_date: sort_param.start_with?('-') ? :desc : :asc)
        else
          reviews.order(review_date: :desc)
        end
      end

      def calculate_rating_distribution(reviews)
        distribution = reviews.group(:rating).count
        {
          '5': distribution[5] || 0,
          '4': distribution[4] || 0,
          '3': distribution[3] || 0,
          '2': distribution[2] || 0,
          '1': distribution[1] || 0
        }
      end
    end
  end
end
