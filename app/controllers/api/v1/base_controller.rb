# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      # JSON:API content type
      before_action :set_jsonapi_content_type

      # Pagination helpers
      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          per_page: collection.limit_value,
          total_pages: collection.total_pages,
          total_count: collection.total_count,
          has_next: collection.next_page.present?,
          has_prev: collection.prev_page.present?
        }
      end

      def pagination_links(collection, base_url)
        {
          self: "#{base_url}?page=#{collection.current_page}",
          first: "#{base_url}?page=1",
          prev: collection.prev_page ? "#{base_url}?page=#{collection.prev_page}" : nil,
          next: collection.next_page ? "#{base_url}?page=#{collection.next_page}" : nil,
          last: "#{base_url}?page=#{collection.total_pages}"
        }.compact
      end

      # Error rendering
      def render_jsonapi_error(status:, code:, title:, detail:, source: nil, meta: nil)
        error = {
          status: status.to_s,
          code: code,
          title: title,
          detail: detail
        }
        error[:source] = source if source
        error[:meta] = meta if meta

        render json: { errors: [error] }, status: status
      end

      def render_not_found(detail = 'Resource not found')
        render_jsonapi_error(
          status: 404,
          code: 'not_found',
          title: 'Not Found',
          detail: detail
        )
      end

      def render_no_results(suggestions: [])
        render_jsonapi_error(
          status: 404,
          code: 'no_results',
          title: 'No Results Found',
          detail: 'No companies found matching your criteria',
          meta: { suggestions: suggestions }
        )
      end

      def render_validation_error(resource)
        errors = resource.errors.map do |error|
          {
            status: '422',
            code: 'validation_error',
            title: 'Validation Error',
            detail: error.full_message,
            source: { pointer: "/data/attributes/#{error.attribute}" }
          }
        end

        render json: { errors: errors }, status: :unprocessable_entity
      end

      private

      def set_jsonapi_content_type
        response.headers['Content-Type'] = 'application/vnd.api+json'
      end

      # Parse include parameter for eager loading
      def parse_includes(include_param)
        return [] unless include_param

        includes = []
        include_param.split(',').each do |inc|
          parts = inc.split('.')
          includes << if parts.length == 1
                        parts[0].to_sym
                      else
                        # Handle nested includes
                        build_nested_include(parts)
                      end
        end
        includes
      end

      def build_nested_include(parts)
        return parts[0].to_sym if parts.length == 1

        { parts[0].to_sym => build_nested_include(parts[1..]) }
      end

      # Safe pagination params
      def page_params
        page = params[:page].to_i
        per_page = params[:per_page].to_i

        page = 1 if page < 1
        per_page = 20 if per_page < 1
        per_page = 100 if per_page > 100

        { page: page, per_page: per_page }
      end
    end
  end
end
