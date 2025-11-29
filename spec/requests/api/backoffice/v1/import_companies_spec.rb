require 'rails_helper'

RSpec.describe 'Api::Backoffice::V1::ImportCompanies', type: :request do
  describe 'POST /api/backoffice/v1/import_companies' do
    let(:csv_content) do
      <<~CSV
        csvname,name,name + address,site,subtypes,phone,full_address,borough,street,city,postal_code,state,country,country_code,latitude,longitude,time_zone,rating,reviews,street_view,working_hours,about,logo,verified,booking_appointment_link,location_link,place_id
        test_csv,"Test Company","Test Company 123 Main St",https://example.com,"Plumber, Repair",+15551234567,"123 Main St, New York, NY 10001",Manhattan,"123 Main St","New York",10001,"New York","United States",US,40.7128,-74.0060,America/New_York,4.5,100,https://maps.google.com,"{""monday"": ""9-5""}","{""description"": ""Best plumber""}",https://example.com/logo.png,TRUE,https://book.com,https://maps.google.com/place,place_123
      CSV
    end

    let(:file) { Rack::Test::UploadedFile.new(StringIO.new(csv_content), 'text/csv', original_filename: 'companies.csv') }

    context 'with valid file' do
      it 'imports companies and returns success' do
        post '/api/backoffice/v1/import_companies', params: { file: file }

        expect(response).to have_http_status(:ok)
        expect(Company.count).to eq(1)
        expect(City.count).to eq(1)
        expect(State.count).to eq(1)
        expect(Country.count).to eq(1)
        json = JSON.parse(response.body)
        expect(json['attributes']['summary']['successful']).to eq(1)

        company = Company.last
        expect(company.name).to eq('Test Company')
        expect(company.city.name).to eq('New York')
        expect(company.city.state.name).to eq('New York')
        expect(company.city.state.country.code).to eq('US')
      end
    end

    context 'without file' do
      it 'returns error' do
        post '/api/backoffice/v1/import_companies'
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
