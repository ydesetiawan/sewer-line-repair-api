module Api
  module Backoffice
    module V1
      class ImportCompaniesController < ApplicationController
        def create
          file = params[:file]

          # Validate file presence
          if file.nil?
            render json: {
              code: 'MISSING_FILE',
              service: 'import_companies',
              title: 'Missing File',
              message: 'No file provided'
            }, status: :bad_request
            return
          end

          # Validate file size (50MB max)
          if file.size > 50.megabytes
            render json: {
              code: 'FILE_TOO_LARGE',
              service: 'import_companies',
              title: 'File Size Exceeded',
              message: 'The uploaded file exceeds the maximum allowed size of 50MB.'
            }, status: :payload_too_large
            return
          end

          # Validate file type
          unless file.content_type == 'text/csv' || file.original_filename.end_with?('.csv')
            render json: {
              code: 'INVALID_FILE_FORMAT',
              service: 'import_companies',
              title: 'Invalid File Format',
              message: 'The uploaded file is not a valid CSV file. Please upload a CSV file with the correct format.'
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
            status_code = case result.code
                          when 'INVALID_FILE_FORMAT'
                            :bad_request
                          when 'FILE_TOO_LARGE'
                            :payload_too_large
                          else
                            :internal_server_error
                          end

            render json: {
              code: result.code || 'INTERNAL_ERROR',
              service: 'import_companies',
              title: error_title(result.code),
              message: result.error
            }, status: status_code
          end
        end

        private

        def error_title(code)
          case code
          when 'INVALID_FILE_FORMAT'
            'Invalid File Format'
          when 'FILE_TOO_LARGE'
            'File Size Exceeded'
          when 'MISSING_FILE'
            'Missing File'
          else
            'Internal Server Error'
          end
        end
      end
    end
  end
end
