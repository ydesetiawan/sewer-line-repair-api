require 'csv'

class ImportCompaniesService
  attr_reader :file

  def initialize(file)
    @file = file
    @summary = {
      total_rows: 0,
      successful: 0,
      failed: 0,
      countries_created: 0,
      countries_updated: 0,
      states_created: 0,
      states_updated: 0,
      cities_created: 0,
      cities_updated: 0,
      companies_created: 0,
      companies_updated: 0
    }
    @errors = []
  end

  def call
    return ImportCsvResultSerializer.failure(error: 'No file provided', code: 'MISSING_FILE') if @file.nil?

    begin
      CSV.foreach(@file.path, headers: true) do |row|
        @summary[:total_rows] += 1
        process_row(row)
      end

      message = if @summary[:successful].positive?
                  "Import completed successfully. #{@summary[:successful]} out of #{@summary[:total_rows]} rows processed successfully."
                else
                  "Import completed with errors. 0 out of #{@summary[:total_rows]} rows processed successfully. Please check the error file for details."
                end

      ImportCsvResultSerializer.success(data: {
                                          message: message,
                                          summary: @summary,
                                          errors: @errors
                                        })
    rescue CSV::MalformedCSVError => e
      ImportCsvResultSerializer.failure(error: "Invalid CSV format: #{e.message}", code: 'INVALID_FILE_FORMAT')
    rescue StandardError => e
      ImportCsvResultSerializer.failure(error: "Unexpected error: #{e.message}", code: 'INTERNAL_ERROR')
    end
  end

  private

  def process_row(row)
    ActiveRecord::Base.transaction do
      # 1. Find or create country
      country = find_or_create_country(row)
      return unless country

      # 2. Find or create state
      state = find_or_create_state(row, country)
      return unless state

      # 3. Find or create city
      city = find_or_create_city(row, state)
      return unless city

      # 4. Find or create company
      company = find_or_create_company(row, city)
      return unless company

      @summary[:successful] += 1
    end
  rescue StandardError => e
    @summary[:failed] += 1
    @errors << {
      row: @summary[:total_rows],
      place_id: row['place_id'],
      company_name: row['name'],
      error: {
        code: 'VALIDATION_ERROR',
        service: 'import_companies',
        title: 'Import Error',
        message: e.message
      }
    }
  end

  def find_or_create_country(row)
    return nil if row['country_code'].blank? || row['country'].blank?

    country = Country.find_by(code: row['country_code'])

    if country
      @summary[:countries_updated] += 1 if country.update(name: row['country'])
    else
      country = Country.create!(
        code: row['country_code'],
        name: row['country'],
        slug: row['country'].parameterize
      )
      @summary[:countries_created] += 1
    end

    country
  end

  def find_or_create_state(row, country)
    return nil if row['state'].blank?

    state = State.find_by(name: row['state'], country: country)

    if state
      @summary[:states_updated] += 1
    else
      state = State.create!(
        country: country,
        name: row['state'],
        code: generate_state_code(row['state']),
        slug: row['state'].parameterize
      )
      @summary[:states_created] += 1
    end

    state
  end

  def find_or_create_city(row, state)
    return nil if row['city'].blank?

    city = City.find_by(name: row['city'], state: state)

    if city
      @summary[:cities_updated] += 1
    else
      city = City.create!(
        state: state,
        name: row['city'],
        slug: row['city'].parameterize
      )
      @summary[:cities_created] += 1
    end

    city
  end

  def find_or_create_company(row, city)
    return nil if row['place_id'].blank?

    company = Company.find_or_initialize_by(id: row['place_id'])
    is_new = company.new_record?

    company.assign_attributes(
      city: city,
      borough: row['borough'],
      name: row['name'],
      slug: row['name'].parameterize || company.slug,
      phone: row['phone'],
      site: row['site'],
      full_address: row['full_address'],
      street_address: row['street'],
      postal_code: row['postal_code'],
      latitude: parse_decimal(row['latitude']),
      longitude: parse_decimal(row['longitude']),
      average_rating: parse_decimal(row['rating']),
      total_reviews: row['reviews'].to_i,
      verified_professional: parse_boolean(row['verified']),
      logo_url: row['logo'],
      booking_appointment_link: row['booking_appointment_link'],
      location_link: row['location_link'],
      timezone: row['time_zone'],
      about: parse_json(row['about']),
      working_hours: parse_json(row['working_hours']),
      subtypes: parse_array(row['subtypes'])
    )

    company.save!

    if is_new
      @summary[:companies_created] += 1
    else
      @summary[:companies_updated] += 1
    end

    company
  end

  def generate_state_code(state_name)
    # Simple state code generation - take first 2 letters and uppercase
    state_name[0..1].upcase
  end

  def parse_decimal(value)
    return nil if value.blank?

    value.to_f
  end

  def parse_boolean(value)
    return false if value.blank?

    %w[TRUE true 1 yes].include?(value.to_s)
  end

  def parse_json(value)
    return {} if value.blank?

    begin
      JSON.parse(value)
    rescue JSON::ParserError
      {}
    end
  end

  def parse_array(value)
    return [] if value.blank?

    # Handle comma-separated values
    value.split(',').map(&:strip)
  end
end
