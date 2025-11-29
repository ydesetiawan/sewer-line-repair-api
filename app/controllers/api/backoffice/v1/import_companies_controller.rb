module Api
  module Backoffice
    module V1
      class ImportCompaniesController < ApplicationController
        include ImportConcern

        def create
          file = params[:file]
          service_name = 'import_companies'

          return unless validate_import_file(file, service_name)

          result = ImportCompaniesService.new(file).call

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
