require 'csv'

class ImportReviewsService
  attr_reader :file

  def initialize(file)
    @file = file
    @summary = {
      total_rows: 0,
      successful: 0,
      failed: 0,
      reviews_created: 0,
      reviews_updated: 0
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
                  "Import completed successfully. #{@summary[:successful]} out of #{@summary[:total_rows]} rows processed successfully." # rubocop:disable Metrics/LineLength
                else
                  "Import completed with errors. 0 out of #{@summary[:total_rows]} rows processed successfully. Please check the error file for details." # rubocop:disable Metrics/LineLength
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
      review = find_or_create_review(row)
      return unless review

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
        service: 'import_reviews',
        title: 'Import Error',
        message: e.message
      }
    }
  end

  def find_or_create_review(row)
    return nil if row['place_id'].blank?

    # Verify company exists
    company = Company.find_by(id: row['place_id'])
    raise "Company with place_id '#{row['place_id']}' not found" unless company

    # Validate rating
    rating = row['review_rating']&.to_i
    raise "Invalid rating value. Expected 1-5, got: #{rating}" if rating && (rating < 1 || rating > 5)

    # Find existing review by company_id and review_link (or review_datetime_utc + author_title)
    review = Review.find_or_initialize_by(
      company_id: row['place_id'],
      review_link: row['review_link'].presence || "#{row['place_id']}_#{row['review_datetime_utc']}_#{row['author_title']}" # rubocop:disable Metrics/LineLength
    )

    is_new = review.new_record?

    review.assign_attributes(
      author_title: row['author_title'],
      author_image: row['author_image'],
      review_text: row['review_text'],
      review_img_urls: parse_array(row['review_img_urls']),
      owner_answer: row['owner_answer'],
      owner_answer_timestamp_datetime_utc: row['owner_answer_timestamp_datetime_utc'],
      review_rating: rating,
      review_datetime_utc: row['review_datetime_utc']
    )

    review.save!

    if is_new
      @summary[:reviews_created] += 1
    else
      @summary[:reviews_updated] += 1
    end

    review
  end

  def parse_datetime(value)
    return nil if value.blank?

    begin
      DateTime.parse(value)
    rescue ArgumentError
      nil
    end
  end

  def parse_array(value)
    return [] if value.blank?

    begin
      JSON.parse(value)
    rescue JSON::ParserError
      # If not JSON, try comma-separated
      value.split(',').map(&:strip)
    end
  end
end
