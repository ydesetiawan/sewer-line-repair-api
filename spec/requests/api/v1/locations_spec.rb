require 'swagger_helper'

RSpec.describe 'api/v1/locations' do
  path '/api/v1/locations/autocomplete' do
    get('Autocomplete location search') do
      tags 'Locations'
      produces 'application/json'
      description 'Search for cities, states, and countries with autocomplete'

      parameter name: :q, in: :query, type: :string, required: true,
                description: 'Search query (minimum 2 characters)'
      parameter name: :type, in: :query, type: :string, required: false,
                description: 'Filter by type (city, state, country)'
      parameter name: :limit, in: :query, type: :integer, required: false,
                description: 'Maximum results to return (default: 10, max: 50)'

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       type: { type: :string, enum: %w[city state country] },
                       name: { type: :string },
                       full_name: { type: :string },
                       state: { type: :string },
                       state_code: { type: :string },
                       code: { type: :string }
                     }
                   }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     query: { type: :string },
                     count: { type: :integer },
                     limit: { type: :integer }
                   }
                 }
               }

        let(:state) { create(:state) }
        let(:city) { create(:city, name: 'Orlando', state: state) }
        let(:q) { 'Orl' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_an(Array)
          expect(data['meta']['query']).to eq('Orl')
        end
      end

      response(400, 'query too short') do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       status: { type: :string },
                       code: { type: :string },
                       title: { type: :string }
                     }
                   }
                 }
               }

        let(:q) { 'O' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors'].first['code']).to eq('query_too_short')
        end
      end
    end
  end

  path '/api/v1/locations/geocode' do
    post 'Geocode an address' do
      tags 'Locations'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :geocode_request, in: :body, schema: {
        type: :object,
        properties: {
          address: { type: :string, example: '1234 Main St, Orlando, FL 32801' }
        }
      }

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     type: { type: :string, example: 'geocode_result' },
                     attributes: {
                       type: :object,
                       properties: {
                         address: { type: :string },
                         latitude: { type: :number },
                         longitude: { type: :number },
                         nearest_city: { type: %i[string null] },
                         nearest_state: { type: %i[string null] },
                         nearby_companies_count: { type: :integer }
                       }
                     }
                   }
                 }
               }

        let(:valid_address) { '1600 Amphitheatre Parkway, Mountain View, CA' }
        let(:coordinates) { [37.4224764, -122.0842499] }
        let(:geocode_request) do
          {
            address: valid_address
          }
        end

        let!(:country) { create(:country, name: 'United States', code: 'US', slug: 'united-states') }
        let!(:state) { create(:state, name: 'California', code: 'CA', slug: 'california', country: country) }
        let!(:test_city) { create(:city, name: 'Mountain View', slug: 'mountain-view', state: state, latitude: 37.4224764, longitude: -122.0842499) }

        before do
          # Stub successful geocoding
          allow(Geocoder).to receive(:coordinates)
            .with(valid_address)
            .and_return(coordinates)
          allow(Geocoder).to receive(:coordinates)
            .with('Invalid Address XYZ123')
            .and_return(nil)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['type']).to eq('geocode_result')
          expect(data['data']['attributes']['latitude']).to be_present
          expect(data['data']['attributes']['longitude']).to be_present
          expect(data['data']['attributes']['nearest_city']).to eq('Mountain View')
        end
      end

      response(400, 'missing address') do
        let(:geocode_request) { { address: nil } }

        run_test!
      end

      response(404, 'geocode failed') do
        let(:geocode_request) do
          {
            address: 'Invalid Address XYZ123'
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors'].first['code']).to eq('geocode_failed')
        end
      end
    end
  end
end
