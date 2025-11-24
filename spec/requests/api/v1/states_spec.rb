require 'swagger_helper'

RSpec.describe 'api/v1/states' do
  path '/api/v1/states/{state_slug}/companies' do
    parameter name: 'state_slug', in: :path, type: :string, description: 'State slug'

    get('List companies in a state') do
      tags 'States'
      produces 'application/json'

      parameter name: :city, in: :query, type: :string, required: false,
                description: 'Filter by city name or slug'
      parameter name: :service_category, in: :query, type: :string, required: false,
                description: 'Filter by service category slug or name'
      parameter name: :verified_only, in: :query, type: :boolean, required: false,
                description: 'Show only verified professionals'
      parameter name: :min_rating, in: :query, type: :number, required: false,
                description: 'Minimum average rating (0-5)'
      parameter name: :sort, in: :query, type: :string, required: false,
                description: 'Sort by field (name, rating, -name, -rating)'
      parameter name: :page, in: :query, type: :integer, required: false,
                description: 'Page number (default: 1)'
      parameter name: :per_page, in: :query, type: :integer, required: false,
                description: 'Items per page (default: 20, max: 100)'

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :string },
                       type: { type: :string, example: 'company' },
                       attributes: { type: :object },
                       relationships: { type: :object },
                       links: { type: :object }
                     }
                   }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     pagination: { type: :object },
                     cities: { type: %i[object null] }
                   }
                 },
                 links: { type: :object }
               }

        let!(:state) { create(:state) }
        let!(:city) { create(:city, state: state) }
        let!(:company) { create(:company, city: city) }
        let(:state_slug) { state.slug }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_an(Array)
          expect(data['meta']['pagination']).to be_present
        end
      end

      response(404, 'state not found') do
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

        let(:state_slug) { 'invalid-state' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors'].first['code']).to eq('state_not_found')
        end
      end
    end
  end
end
