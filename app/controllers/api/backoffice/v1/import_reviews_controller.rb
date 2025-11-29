module Api
  module Backoffice
    module V1
      class ImportReviewsController < ApplicationController
        include ImportConcern

        def create
          file = params[:file]
          service_name = 'import_reviews'

          return unless validate_import_file(file, service_name)

          result = ImportReviewsService.new(file).call

          if result.success?
            render_import_success(result, service_name)
          else
            render_import_error(result, service_name)
          end
        end
      end
    end
  end
end
