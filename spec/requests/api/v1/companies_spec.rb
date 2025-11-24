require 'swagger_helper'

RSpec.describe 'api/v1/companies' do
  path '/api/v1/companies/search' do
    get('Search companies') do
      tags 'Companies'
      produces 'application/json'
      parameter name: :city, in: :query, type: :string, required: false,
                description: 'Filter by city name'
      parameter name: :state, in: :query, type: :string, required: false,
                description: 'Filter by state code or name'
      parameter name: :country, in: :query, type: :string, required: false,
                description: 'Filter by country code or name'
      parameter name: :lat, in: :query, type: :number, required: false,
                description: 'Latitude for location-based search'
      parameter name: :lng, in: :query, type: :number, required: false,
                description: 'Longitude for location-based search'
      parameter name: :radius, in: :query, type: :number, required: false,
                description: 'Search radius in miles (default: 25)'
      parameter name: :address, in: :query, type: :string, required: false,
                description: 'Address to geocode and search near'
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
                       attributes: {
                         type: :object,
                         properties: {
                           name: { type: :string },
                           slug: { type: :string },
                           phone: { type: :string },
                           email: { type: :string },
                           website: { type: :string },
                           average_rating: { type: :string },
                           total_reviews: { type: :integer },
                           verified_professional: { type: :boolean }
                         }
                       },
                       relationships: { type: :object },
                       links: {
                         type: :object,
                         properties: {
                           self: { type: :string }
                         }
                       }
                     }
                   }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     pagination: {
                       type: :object,
                       properties: {
                         current_page: { type: :integer },
                         per_page: { type: :integer },
                         total_pages: { type: :integer },
                         total_count: { type: :integer }
                       }
                     }
                   }
                 },
                 links: { type: :object }
               }

        let(:test_city) { create(:city, name: 'Orlando') }
        let!(:company) { create(:company, city: test_city) }
        let(:city) { 'Orlando' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_an(Array)
          expect(data['meta']['pagination']).to be_present
        end
      end

      response(200, 'no results found') do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :string },
                       type: { type: :string, example: 'company' },
                       attributes: {
                         type: :object,
                         properties: {
                           name: { type: :string },
                           slug: { type: :string },
                           phone: { type: :string },
                           email: { type: :string },
                           website: { type: :string },
                           average_rating: { type: :string },
                           total_reviews: { type: :integer },
                           verified_professional: { type: :boolean }
                         }
                       },
                       relationships: { type: :object },
                       links: {
                         type: :object,
                         properties: {
                           self: { type: :string }
                         }
                       }
                     }
                   }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     pagination: {
                       type: :object,
                       properties: {
                         current_page: { type: :integer },
                         per_page: { type: :integer },
                         total_pages: { type: :integer },
                         total_count: { type: :integer }
                       }
                     }
                   }
                 },
                 links: { type: :object }
               }

        let(:city) { 'NonexistentCity' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_an(Array)
          expect(data['data']).to be_empty
          expect(data['meta']['pagination']['total_items']).to eq(0)
        end
      end
    end
  end

  path '/api/v1/companies/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'Company ID'

    get('Show company details') do
      tags 'Companies'
      produces 'application/json'
      description 'Get detailed information about a specific company'

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :string },
                     type: { type: :string },
                     attributes: { type: :object },
                     relationships: { type: :object },
                     links: { type: :object }
                   }
                 },
                 included: { type: :array }
               }

        let(:city) { create(:city) }
        let(:company) { create(:company, city: city) }
        let(:id) { company.slug }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['type']).to eq('company')
          expect(data['data']['id']).to eq(company.id.to_s)
        end
      end

      response(404, 'company not found') do
        let(:id) { 'invalid' }

        run_test!
      end
    end
  end
end
