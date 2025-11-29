module Api
  module Backoffice
    module V1
      class ImportCompaniesController < ApplicationController
        def create
          file = params[:file]

          if file.nil?
            render json: {
              code: 'INVALID_REQUEST',
              service: 'import_companies',
              title: 'Missing File',
              message: 'No file provided'
            }, status: :bad_request
            return
          end

          result = ImportCompaniesService.new(file).call

          if result.success?
            render json: {
              id: "imp_#{Time.now.to_i}_#{SecureRandom.hex(3)}",
              type: 'import_companies',
              attributes: result.data
            }, status: :ok
          else
            render json: {
              code: result.code || 'IMPORT_FAILED',
              service: 'import_companies',
              title: 'Import Failed',
              message: result.error
            }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
