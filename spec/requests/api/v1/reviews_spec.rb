# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/reviews' do
  path '/api/v1/companies/{company_id}/reviews' do
    parameter name: :company_id, in: :path, type: :string, description: 'Company ID'

    get 'List company reviews' do
      tags 'Reviews'
      produces 'application/vnd.api+json'

      parameter name: :verified_only, in: :query, type: :boolean, required: false, description: 'Verified reviews only'
      parameter name: :min_rating, in: :query, type: :integer, required: false, description: 'Minimum rating (1-5)'
      parameter name: :sort, in: :query, type: :string, required: false, description: 'Sort: "review_date", "-review_date", "rating", "-rating"'
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number (default: 1)'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Results per page (default: 20, max: 100)'

      response '200', 'reviews found' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :string },
                       type: { type: :string, example: 'review' },
                       attributes: {
                         type: :object,
                         properties: {
                           reviewer_name: { type: :string },
                           review_date: { type: :string, format: 'date' },
                           rating: { type: :integer },
                           review_text: { type: :string },
                           verified: { type: :boolean },
                           created_at: { type: :string, format: 'date-time' }
                         }
                       },
                       relationships: {
                         type: :object,
                         properties: {
                           company: {
                             type: :object,
                             properties: {
                               data: {
                                 type: :object,
                                 properties: {
                                   id: { type: :string },
                                   type: { type: :string, example: 'company' }
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
                 meta: {
                   type: :object,
                   properties: {
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
                     },
                     rating_distribution: {
                       type: :object,
                       properties: {
                         '1': { type: :integer },
                         '2': { type: :integer },
                         '3': { type: :integer },
                         '4': { type: :integer },
                         '5': { type: :integer }
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

        let(:company_id) { Company.first.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_an(Array)
          expect(data['meta']).to have_key('pagination')
          expect(data['meta']).to have_key('rating_distribution')
        end
      end

      response '200', 'filtered reviews' do
        let(:company_id) { Company.first.id }
        let(:verified_only) { true }
        let(:min_rating) { 4 }
        let(:sort) { '-review_date' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_an(Array)
        end
      end

      response '404', 'company not found' do
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

        let(:company_id) { 'invalid' }

        run_test!
      end
    end
  end
end
