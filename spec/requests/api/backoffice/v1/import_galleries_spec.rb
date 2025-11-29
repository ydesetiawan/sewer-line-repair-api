require 'swagger_helper'

RSpec.describe 'Api::Backoffice::V1::ImportGalleries' do
  path '/api/backoffice/v1/import_galleries' do
    post 'Import gallery images from CSV' do
      tags 'Backoffice - Import'
      consumes 'multipart/form-data'
      produces 'application/json'

      parameter name: :file, in: :formData, type: :file, required: true, description: 'CSV file containing gallery data'

      response '200', 'galleries imported successfully' do
        let(:company) { create(:company) }
        let(:csv_content) do
          <<~CSV
            name,place_id,google_maps_photos.photo_url,google_maps_photos.photo_url_big,google_maps_photos.photo_date,google_maps_photos.photo_source_video
            #{company.name},#{company.id},https://example.com/photo1.jpg,https://example.com/photo1_big.jpg,2023-11-29 10:00:00,
            #{company.name},#{company.id},https://example.com/photo2.jpg,https://example.com/photo2_big.jpg,2023-11-28 15:30:00,https://example.com/video.mp4
          CSV
        end
        let(:file) do
          Rack::Test::UploadedFile.new(
            StringIO.new(csv_content),
            'text/csv',
            original_filename: 'galleries.csv'
          )
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['type']).to eq('import_galleries')
          expect(data['attributes']['summary']['total_rows']).to eq(2)
          expect(data['attributes']['summary']['successful']).to eq(2)
          expect(data['attributes']['summary']['galleries_created']).to eq(2)
        end
      end

      response '400', 'no file provided' do
        let(:file) { nil }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['code']).to eq('MISSING_FILE')
          expect(data['service']).to eq('import_galleries')
        end
      end
    end
  end
end
