require 'swagger_helper'

RSpec.describe 'api/v1/locations' do
  path '/api/v1/locations/autocomplete' do
    get('Autocomplete location search') do
      tags 'Locations'
      produces 'application/vnd.api+json'
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
        let!(:city) { create(:city, name: 'Orlando', state: state) }
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
    post('Geocode an address') do
      tags 'Locations'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'
      description 'Convert an address to coordinates and find nearby information'

      parameter name: :geocode_request, in: :body, schema: {
        type: :object,
        properties: {
          data: {
            type: :object,
            properties: {
              attributes: {
                type: :object,
                properties: {
                  address: { type: :string, example: '1234 Main St, Orlando, FL 32801' }
                },
                required: ['address']
              }
            }
          }
        },
        required: ['data']
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
                         nearest_city: { type: :string },
                         nearest_state: { type: :string },
                         nearby_companies_count: { type: :integer }
                       }
                     }
                   }
                 }
               }

        let(:state) { create(:state, name: 'Florida') }
        let(:city) { create(:city, name: 'Orlando', state: state) }
        let(:geocode_request) do
          {
            data: {
              attributes: {
                address: '1234 Main St, Orlando, FL 32801'
              }
            }
          }
        end

        before do
          allow(Geocoder).to receive(:coordinates).and_return([28.5383, -81.3792])
          allow(City).to receive_message_chain(:near, :first).and_return(city)
          allow(Company).to receive_message_chain(:near, :count).and_return(5)
          allow(Geocoder).to receive(:coordinates).and_return(nil)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['type']).to eq('geocode_result')
          expect(data['data']['attributes']['latitude']).to be_present
          expect(data['data']['attributes']['longitude']).to be_present
        end
      end

      response(400, 'missing address') do
        let(:geocode_request) { { data: { attributes: {} } } }

        run_test!
      end

      response(404, 'geocode failed') do
        let(:geocode_request) do
          {
            data: {
              attributes: {
                address: 'Invalid Address'
              }
            }
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
