module ImportConcern
  extend ActiveSupport::Concern

  private

  def validate_import_file?(file, service_name)
    # Validate file presence
    if file.blank? || !file.respond_to?(:read)
      render_error(ErrorInfo::MISSING_FILE, service_name, :bad_request)
      return false
    end

    # Validate file size (50MB max)
    if file.size > 50.megabytes
      render_error(ErrorInfo::FILE_TOO_LARGE, service_name, :payload_too_large)
      return false
    end

    # Validate file type
    unless file.respond_to?(:content_type) && (file.content_type == 'text/csv' || file.original_filename.end_with?('.csv'))
      render_error(ErrorInfo::INVALID_FILE_FORMAT, service_name, :bad_request)
      return false
    end

    true
  end

  def render_import_success(result, import_type)
    render json: {
      id: "imp_#{Time.now.to_i}_#{SecureRandom.hex(3)}",
      type: import_type,
      attributes: result.data
    }, status: :ok
  end

  def render_import_error(result, service_name)
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
      service: service_name,
      title: error_title(result.code),
      message: result.error
    }, status: status_code
  end

  def render_error(error_info, service_name, status)
    error_hash = error_info.to_hash
    error_hash[:service] = service_name
    render json: error_hash, status: status
  end

  def error_title(code)
    case code
    when 'INVALID_FILE_FORMAT'
      ErrorInfo::INVALID_FILE_FORMAT.title
    when 'FILE_TOO_LARGE'
      ErrorInfo::FILE_TOO_LARGE.title
    when 'MISSING_FILE'
      ErrorInfo::MISSING_FILE.title
    else
      'Internal Server Error'
    end
  end
end
