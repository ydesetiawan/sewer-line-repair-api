module Api
  module V1
    class ReviewsController < BaseController
      # GET /api/v1/companies/:company_id/reviews
      def index
        reviews = Review.where(company_id: params[:company_id])

        reviews = filter_by_rating(reviews)

        # Apply sorting
        reviews = apply_sorting(reviews)

        reviews = reviews.page(params[:page].presence&.to_i || 1)
                         .per(params[:per_page].presence&.to_i || 50)

        render_collection(ReviewSerializer, reviews)
      end

      private

      def filter_by_rating(reviews)
        return reviews if params[:ratings].blank?

        ratings = Array(params[:ratings]).map(&:to_i).select { |r| (1..5).include?(r) }
        return reviews if ratings.empty?

        reviews.where(review_rating: ratings)
      end

      def apply_sorting(reviews)
        sort_param = params[:sort] || '-review_datetime_utc'

        case sort_param
        when 'review_rating', '-review_rating'
          reviews.order(review_rating: sort_param.start_with?('-') ? :desc : :asc)
        when 'review_datetime_utc', '-review_datetime_utc'
          reviews.order(review_datetime_utc: sort_param.start_with?('-') ? :desc : :asc)
        else
          reviews.order(review_datetime_utc: :desc)
        end
      end
    end
  end
end
