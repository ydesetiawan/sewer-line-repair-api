# frozen_string_literal: true

module ErrorInfo # rubocop:disable Metrics/ModuleLength
  # The ErrorData struct provides memory-efficient error representation
  ErrorData = Struct.new(:code, :service, :title, :message) do
    def to_hash
      {
        code: code,
        service: service,
        title: title,
        message: message
      }
    end

    def to_json(*_args)
      to_hash.to_json
    end
  end

  # Pre-defined common errors for reuse
  INTERNAL_SERVER_ERROR = ErrorData.new(
    '500',
    Configs::SERVER_IDENTIFIER,
    'Internal Server Error',
    'An unexpected error occurred while processing your request.'
  )

  # Common error instances
  CONNECTION_FAILED = ErrorData.new(
    '503',
    Configs::SERVER_IDENTIFIER,
    'Service Unavailable',
    'Failed to connect to surrounding service!. Please try again later.'
  )

  CONNECTION_TIMEOUT = ErrorData.new(
    '504',
    Configs::SERVER_IDENTIFIER,
    'Gateway Timeout',
    'Connection to surrounding service timed out!. Please try again later.'
  )

  NOT_FOUND = ErrorData.new(
    '404',
    Configs::SERVER_IDENTIFIER,
    'Not Found',
    'Record not found. Please check the provided identifier or resource.'
  )

  BAD_REQUEST = ErrorData.new(
    '400',
    Configs::SERVER_IDENTIFIER,
    'Bad Request',
    'The request could not be processed due to invalid input or missing parameters.'
  )

  UNAUTHORIZED = ErrorData.new(
    '401',
    Configs::SERVER_IDENTIFIER,
    'Unauthorized',
    'Unauthorized access. Please check your credentials or permissions.'
  )

  FORBIDDEN = ErrorData.new(
    '403',
    Configs::SERVER_IDENTIFIER,
    'Forbidden',
    'Forbidden access. You do not have permission to perform this action.'
  )

  UNPROCESSABLE_ENTITY = ErrorData.new(
    '422',
    Configs::SERVER_IDENTIFIER,
    'Business Logic Error',
    'Unprocessable entity due to business rule violation or invalid input. Please check your request and try again.'
  )

  CONFLICT = ErrorData.new(
    '409',
    Configs::SERVER_IDENTIFIER,
    'Conflict',
    'The request could not be completed due to a conflict with the current state of the resource.'
  )

  # Import-specific errors
  MISSING_FILE = ErrorData.new(
    'MISSING_FILE',
    'import',
    'Missing File',
    'No file provided'
  )

  INVALID_FILE_FORMAT = ErrorData.new(
    'INVALID_FILE_FORMAT',
    'import',
    'Invalid File Format',
    'The uploaded file is not a valid CSV file. Please upload a CSV file with the correct format.'
  )

  FILE_TOO_LARGE = ErrorData.new(
    'FILE_TOO_LARGE',
    'import',
    'File Size Exceeded',
    'The uploaded file exceeds the maximum allowed size of 50MB.'
  )

  # Factory methods for creating custom errors
  def self.unprocessable_entity(error_message = nil, service_name = nil, custom_code = nil, title = nil) # rubocop:disable Metrics/ParameterLists
    ErrorData.new(
      custom_code || UNPROCESSABLE_ENTITY.code,
      service_name || UNPROCESSABLE_ENTITY.service,
      title || UNPROCESSABLE_ENTITY.title,
      error_message || UNPROCESSABLE_ENTITY.message
    )
  end

  def self.connection_failed(service_name = nil)
    ErrorData.new(
      CONNECTION_FAILED.code,
      service_name,
      CONNECTION_FAILED.title,
      CONNECTION_FAILED.message
    )
  end

  def self.internal_server_error(error_message = nil, service_name = nil)
    ErrorData.new(
      INTERNAL_SERVER_ERROR.code,
      service_name || INTERNAL_SERVER_ERROR.code,
      INTERNAL_SERVER_ERROR.title,
      error_message || INTERNAL_SERVER_ERROR.message
    )
  end

  def self.connection_timeout(error_message = nil, service_name = nil)
    ErrorData.new(
      CONNECTION_TIMEOUT.code,
      service_name || CONNECTION_TIMEOUT.service,
      CONNECTION_TIMEOUT.title,
      error_message || CONNECTION_TIMEOUT.message
    )
  end

  def self.not_found(error_message = nil, service_name = nil)
    ErrorData.new(
      NOT_FOUND.code,
      service_name || NOT_FOUND.service,
      NOT_FOUND.title,
      error_message || NOT_FOUND.message
    )
  end

  def self.bad_request(error_message = nil, service_name = nil)
    ErrorData.new(
      BAD_REQUEST.code,
      service_name || BAD_REQUEST.service,
      BAD_REQUEST.title,
      error_message || BAD_REQUEST.message
    )
  end
end
