# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/states' do
  path '/api/v1/states/{state_slug}/companies' do
    parameter name: :state_slug, in: :path, type: :string, description: 'State slug or code (e.g., "florida" or "FL")'

    get 'List companies in a state' do
      tags 'States'
      produces 'application/vnd.api+json'

      parameter name: :city, in: :query, type: :string, required: false, description: 'Filter by city slug'
      parameter name: :service_category, in: :query, type: :string, required: false, description: 'Service category slug'
      parameter name: :verified_only, in: :query, type: :boolean, required: false, description: 'Verified professionals only'
      parameter name: :min_rating, in: :query, type: :number, required: false, description: 'Minimum rating (0-5)'
      parameter name: :sort, in: :query, type: :string, required: false, description: 'Sort: "rating", "-rating", "name", "-name"'
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number (default: 1)'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Results per page (default: 20, max: 100)'
      parameter name: :include, in: :query, type: :string, required: false, description: 'Include relationships: "city,service_categories"'

      response '200', 'companies found' do
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
                           verified_professional: { type: :boolean },
                           certified_partner: { type: :boolean },
                           created_at: { type: :string, format: 'date-time' },
                           updated_at: { type: :string, format: 'date-time' }
                         }
                       },
                       relationships: {
                         type: :object,
                         properties: {
                           city: {
                             type: :object,
                             properties: {
                               data: {
                                 type: :object,
                                 properties: {
                                   id: { type: :string },
                                   type: { type: :string, example: 'city' }
                                 }
                               }
                             }
                           }
                         }
                       },
                       links: {
                         type: :object,
                         properties: {
                           self: { type: :string }
                         }
                       }
                     }
                   }
                 },
                 included: {
                   type: :array,
                   items: { type: :object }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     state: {
                       type: :object,
                       properties: {
                         id: { type: :string },
                         name: { type: :string },
                         code: { type: :string },
                         slug: { type: :string },
                         total_companies: { type: :integer },
                         total_cities: { type: :integer }
                       }
                     },
                     pagination: {
                       type: :object,
                       properties: {
                         current_page: { type: :integer },
                         per_page: { type: :integer },
                         total_pages: { type: :integer },
                         total_count: { type: :integer },
                         has_next: { type: :boolean },
                         has_prev: { type: :boolean }
                       }
                     }
                   }
                 },
                 links: {
                   type: :object,
                   properties: {
                     self: { type: :string },
                     first: { type: :string },
                     next: { type: :string },
                     last: { type: :string }
                   }
                 }
               }

        let(:state_slug) { 'florida' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_an(Array)
          expect(data['meta']).to have_key('state')
          expect(data['meta']['state']['slug']).to eq('florida')
        end
      end

      response '200', 'companies with filters' do
        let(:state_slug) { 'FL' }
        let(:city) { 'orlando' }
        let(:verified_only) { true }
        let(:min_rating) { 4.0 }
        let(:sort) { '-rating' }
        let(:include) { 'city' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_an(Array)
          expect(data['meta']['state']['code']).to eq('FL')
        end
      end

      response '404', 'state not found' do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       status: { type: :string },
                       code: { type: :string },
                       title: { type: :string },
                       detail: { type: :string }
                     }
                   }
                 }
               }

        let(:state_slug) { 'nonexistent' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to be_an(Array)
          expect(data['errors'].first['code']).to eq('not_found')
        end
      end
    end
  end
end
