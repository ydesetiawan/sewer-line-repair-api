module Api
  module V1
    class BaseController < ApplicationController
      before_action :set_default_format

      private

      def set_default_format
        request.format = :json unless params[:format]
      end

      def render_jsonapi(resource, options = {})
        if resource.nil?
          render_error('Resource not found', :not_found)
          return
        end

        serializer_class = options.delete(:serializer) || "#{resource.class.name}Serializer".constantize
        relationships = parse_relationships(params[:with])

        render json: serializer_class.new(
          resource,
          options.merge(include: relationships)
        ).serializable_hash.to_json,
               status: options[:status] || :ok,
               content_type: 'application/vnd.api+json'
      end

      def render_jsonapi_collection(collection, options = {})
        serializer_class = options.delete(:serializer) || infer_serializer_class(collection)
        relationships = parse_relationships(params[:with])

        # Paginate collection
        paginated = collection.page(params[:page]).per(per_page)

        serialized = serializer_class.new(
          paginated,
          options.merge(
            include: relationships,
            meta: pagination_meta(paginated).merge(options[:meta] || {}),
            links: pagination_links(paginated)
          )
        ).serializable_hash

        render json: serialized.to_json,
               status: options[:status] || :ok,
               content_type: 'application/vnd.api+json'
      end

      // ...existing code...

      def parse_relationships(with_param)
        return [] if with_param.blank?

        with_param.split(',').map(&:strip).map do |path|
          path.split('.').map(&:to_sym).reduce([]) do |acc, part|
            acc.empty? ? [part] : [acc.last => part]
          end.last
        end
      end

      def infer_serializer_class(collection)
        model_name = collection.klass.name
        "#{model_name}Serializer".constantize
      end

      def pagination_meta(collection)
        {
          pagination: {
            current_page: collection.current_page,
            per_page: collection.limit_value,
            total_pages: collection.total_pages,
            total_count: collection.total_count
          }
        }
      end

      def pagination_links(collection)
        base_url = request.base_url + request.path
        query_params = request.query_parameters.except(:page)

        {
          self: build_url(base_url, query_params.merge(page: collection.current_page)),
          first: build_url(base_url, query_params.merge(page: 1)),
          last: build_url(base_url, query_params.merge(page: collection.total_pages)),
          prev: collection.prev_page ? build_url(base_url, query_params.merge(page: collection.prev_page)) : nil,
          next: collection.next_page ? build_url(base_url, query_params.merge(page: collection.next_page)) : nil
        }.compact
      end

      def build_url(base_url, params)
        "#{base_url}?#{params.to_query}"
      end

      def per_page
        per = params[:per_page].to_i
        per.positive? ? [per, 100].min : 20
      end
    end
  end
end
