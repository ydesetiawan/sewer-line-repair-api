require 'csv'

class ImportGalleriesService
  attr_reader :file

  def initialize(file)
    @file = file
    @summary = {
      total_rows: 0,
      successful: 0,
      failed: 0,
      galleries_created: 0,
      galleries_updated: 0
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

  def message
    if @summary[:successful].positive?
      "Import completed successfully. #{@summary[:successful]} out of #{@summary[:total_rows]} rows processed successfully." # rubocop:disable Metrics/LineLength
    else
      "Import completed with errors. 0 out of #{@summary[:total_rows]} rows processed successfully. Please check the error file for details." # rubocop:disable Metrics/LineLength
    end
  end

  def process_row(row)
    ActiveRecord::Base.transaction do
      gallery = find_or_create_gallery(row)
      return unless gallery

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
        service: 'import_galleries',
        title: 'Import Error',
        message: e.message
      }
    }
  end

  def find_or_create_gallery(row)
    return nil if row['place_id'].blank?

    # Verify company exists
    company = Company.find_by(id: row['place_id'])
    raise "Company with place_id '#{row['place_id']}' not found" unless company

    # Find existing gallery by company_id and image_url
    gallery = GalleryImage.find_or_initialize_by(
      company_id: row['place_id'],
      image_url: row['google_maps_photos.photo_url']
    )

    is_new = gallery.new_record?

    gallery.assign_attributes(
      thumbnail_url: row['google_maps_photos.photo_url'],
      video_url: row['google_maps_photos.photo_source_video'],
      image_datetime_utc: parse_datetime(row['google_maps_photos.photo_date'])
    )

    gallery.save!

    if is_new
      @summary[:galleries_created] += 1
    else
      @summary[:galleries_updated] += 1
    end

    gallery
  end

  def parse_datetime(value)
    return nil if value.blank?

    begin
      DateTime.parse(value)
    rescue ArgumentError
      nil
    end
  end
end
