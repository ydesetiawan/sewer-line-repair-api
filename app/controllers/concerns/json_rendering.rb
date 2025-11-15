module JsonRendering
  extend ActiveSupport::Concern

  included do # rubocop:disable Metrics/BlockLength
    def render_unprocessable_entity_response(exception)
      render json: { errors: exception.record.errors }, status: :unprocessable_content
    end

    def render_ok(message = nil)
      render json: { message: }, status: :ok
    end

    def render_unprocessable_entity(message = nil)
      render json: { message: }, status: :unprocessable_content
    end

    def render_not_found_response
      render json: { error: ErrorInfo::NOT_FOUND.to_hash }, status: :not_found
    end

    def render_unprocessable_entity_exception(error)
      render json: { error: error.errors }, status: :unprocessable_content
    end

    def render_internal_server_exception(error)
      render json: {
        error: ErrorInfo.internal_server_error(error.message).to_hash
      }, status: :internal_server_error
    end

    def render_not_found_exception(message = 'Record not found')
      render json: { error: ErrorInfo.not_found(message).to_hash }, status: :not_found
    end

    def render_forbidden
      render json: { error: ErrorInfo::FORBIDDEN.to_hash }, status: :forbidden
    end

    def render_unauthorized
      render json: { error: ErrorInfo::UNAUTHORIZED.to_hash }, status: :unauthorized
    end

    def render_created(message = 'Record created')
      render json: { message: }, status: :created
    end

    def render_base_error(error)
      render json: {
        error: {
          code: error.code,
          service: error.service,
          title: error.title,
          message: error.message,
          data: error.data
        }
      }, status: error.http_status
    end

    def render_surrounding_error(error)
      render json: {
        error: {
          code: error.code,
          service: error.service,
          title: error.title,
          message: error.message,
          data: error.data
        }
      }, status: error.http_status || :internal_server_error
    end

    def render_json(serializer, obj, options = {})
      return render_collection(serializer, obj, options) if obj.is_a?(::ActiveRecord::Relation)

      render_record(serializer, obj, options)
    end

    def render_collection(serializer, collection, options = {})
      options = meta_pagination(collection, options)
      render_record(serializer, collection, options)
    end

    def render_record(serializer, record, options = {})
      http_status = options[:status] || :ok
      render json: serializer.new(record, options), status: http_status
    end

    def render_json_error_validation(obj)
      render json: { errors: obj.errors, error_full_message: obj.errors.full_messages }, status: :unprocessable_content
    end

    def render_contract_error_validation(result)
      render json: { errors: result.errors(full: true).to_h }, status: :unprocessable_content
    end

    def render_api_response(response)
      render json: response.body, status: response.status
    end
  end

  private

  def meta_pagination(paginated_obj, options = {})
    options[:meta] = {} unless options.key?(:meta)
    meta_options = options[:meta].merge(generate_pagination(paginated_obj))
    options[:meta] = meta_options
    options
  end

  def generate_pagination(paginated_obj)
    {
      pagination: {
        current_page: paginated_obj.current_page,
        prev_page: paginated_obj.prev_page,
        next_page: paginated_obj.next_page,
        total_items: paginated_obj.total_count,
        total_pages: paginated_obj.total_pages
      }
    }
  end
end
