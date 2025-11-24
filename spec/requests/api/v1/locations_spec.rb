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
end
