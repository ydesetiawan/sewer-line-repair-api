# frozen_string_literal: true
module Api
  module V1
    class GalleriesController < BaseController

      # GET /api/v1/companies/:company_id/galleries
      def index
        reviews = GalleryImage.where(company_id: params[:company_id])

        reviews = reviews.page(params[:page].presence&.to_i || 1)
                         .per(params[:per_page].presence&.to_i || 50)

        render_collection(GalleryImageSerializer, reviews)
      end
    end
  end
end
