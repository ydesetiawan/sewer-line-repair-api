require 'swagger_helper'

RSpec.describe 'Api::Backoffice::V1::ImportReviews' do
  path '/api/backoffice/v1/import_reviews' do
    post 'Import reviews from CSV' do
      tags 'Backoffice - Import'
      consumes 'multipart/form-data'
      produces 'application/json'

      parameter name: :file, in: :formData, type: :file, required: true, description: 'CSV file containing reviews data'

      response '200', 'reviews imported successfully' do
        let(:company) { create(:company) }
        let(:csv_content) do
          <<~CSV
            name,place_id,reviews_text,review_rating,author_title,author_image,review_img_urls,owner_answer,owner_answer_timestamp_datetime_utc,review_link,review_datetime_utc
            #{company.name},#{company.id},Great service!,5,John Doe,https://example.com/avatar.jpg,[],Thank you!,2023-11-29 10:00:00,https://maps.google.com/review/123,2023-11-28 15:30:00
            #{company.name},#{company.id},Excellent work,4,Jane Smith,https://example.com/avatar2.jpg,[],,,https://maps.google.com/review/123,2023-11-27 12:00:00
          CSV
        end
        let(:file) do
          Rack::Test::UploadedFile.new(
            StringIO.new(csv_content),
            'text/csv',
            original_filename: 'reviews.csv'
          )
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['type']).to eq('import_reviews')
          expect(data['attributes']['summary']['total_rows']).to eq(2)
          expect(data['attributes']['summary']['successful']).to eq(2)
        end
      end

      response '400', 'no file provided' do
        let(:file) { nil }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['code']).to eq('MISSING_FILE')
          expect(data['service']).to eq('import_reviews')
        end
      end
    end
  end
end
