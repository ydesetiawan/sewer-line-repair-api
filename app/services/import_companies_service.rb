require 'csv'

class ImportCompaniesService
  attr_reader :file

  def initialize(file)
    @file = file
    @results = {
      total: 0,
      created: 0,
      updated: 0,
      failed: 0,
      errors: []
    }
  end

  def call
    begin
      csv_data = File.read(file.tempfile.path)
      csv = CSV.parse(csv_data, headers: true)

      csv.each_with_index do |row, index|
        @results[:total] += 1
        process_row(row, index)
      end

      Result.success(data: @results)
    rescue CSV::MalformedCSVError => e
      Result.failure(error: "Invalid CSV format: #{e.message}", code: 'INVALID_CSV')
    rescue StandardError => e
      Result.failure(error: "Import failed: #{e.message}", code: 'IMPORT_ERROR')
    end
  end

  private

  def process_row(row, index)
    # Find or initialize company by ID or name
    company = find_or_initialize_company(row)

    # Map CSV columns to company attributes
    company.assign_attributes(map_attributes(row))

    if company.save
      company.new_record? ? @results[:created] += 1 : @results[:updated] += 1
    else
      @results[:failed] += 1
      @results[:errors] << {
        row: index + 2, # +2 because index is 0-based and header is row 1
        errors: company.errors.full_messages
      }
    end
  rescue StandardError => e
    @results[:failed] += 1
    @results[:errors] << {
      row: index + 2,
      errors: [e.message]
    }
  end

  def find_or_initialize_company(row)
    # Try to find by ID if provided
    if row['id'].present?
      Company.find_or_initialize_by(id: row['id'])
    elsif row['name'].present? && row['city_id'].present?
      # Find by name and city
      Company.find_or_initialize_by(
        name: row['name'],
        city_id: row['city_id']
      )
    else
      Company.new
    end
  end

  def map_attributes(row)
    attrs = {}

    # Basic information
    attrs[:id] = row['id'] if row['id'].present?
    attrs[:name] = row['name'] if row['name'].present?
    attrs[:phone] = row['phone'] if row['phone'].present?
    attrs[:email] = row['email'] if row['email'].present?
    attrs[:website] = row['website'] if row['website'].present?

    # Address information
    attrs[:street_address] = row['street_address'] if row['street_address'].present?
    attrs[:zip_code] = row['zip_code'] if row['zip_code'].present?
    attrs[:borough] = row['borough'] if row['borough'].present?

    # Location
    attrs[:city_id] = row['city_id'] if row['city_id'].present?
    attrs[:latitude] = row['latitude'].to_f if row['latitude'].present?
    attrs[:longitude] = row['longitude'].to_f if row['longitude'].present?

    # Description and details
    attrs[:description] = row['description'] if row['description'].present?
    attrs[:specialty] = row['specialty'] if row['specialty'].present?
    attrs[:service_level] = row['service_level'] if row['service_level'].present?

    # Verification flags
    attrs[:verified_professional] = parse_boolean(row['verified_professional'])
    attrs[:licensed] = parse_boolean(row['licensed'])
    attrs[:insured] = parse_boolean(row['insured'])
    attrs[:background_checked] = parse_boolean(row['background_checked'])
    attrs[:certified_partner] = parse_boolean(row['certified_partner'])
    attrs[:service_guarantee] = parse_boolean(row['service_guarantee'])

    # Additional fields
    attrs[:logo_url] = row['logo_url'] if row['logo_url'].present?
    attrs[:booking_appointment_link] = row['booking_appointment_link'] if row['booking_appointment_link'].present?
    attrs[:timezone] = row['timezone'] if row['timezone'].present?

    # JSONB fields
    attrs[:about] = parse_json(row['about']) if row['about'].present?
    attrs[:working_hours] = parse_json(row['working_hours']) if row['working_hours'].present?

    # Array fields
    attrs[:subtypes] = parse_array(row['subtypes']) if row['subtypes'].present?

    attrs.compact
  end

  def parse_boolean(value)
    return nil if value.blank?

    %w[true 1 yes y].include?(value.to_s.downcase)
  end

  def parse_json(value)
    return nil if value.blank?

    JSON.parse(value)
  rescue JSON::ParserError
    nil
  end

  def parse_array(value)
    return [] if value.blank?

    # Handle JSON array or comma-separated string
    if value.start_with?('[')
      JSON.parse(value)
    else
      value.split(',').map(&:strip)
    end
  rescue JSON::ParserError
    value.split(',').map(&:strip)
  end
end

# Result object for service responses
class Result
  attr_reader :data, :error, :code

  def initialize(success:, data: nil, error: nil, code: nil)
    @success = success
    @data = data
    @error = error
    @code = code
  end

  def success?
    @success
  end

  def self.success(data: nil)
    new(success: true, data: data)
  end

  def self.failure(error:, code: nil)
    new(success: false, error: error, code: code)
  end
end


