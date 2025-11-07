require 'swagger_helper'

RSpec.describe 'api/v1/reviews' do
  path '/api/v1/companies/{company_id}/reviews' do
    parameter name: 'company_id', in: :path, type: :string, description: 'Company ID'

    get('List company reviews') do
      tags 'Reviews'
      produces 'application/vnd.api+json'
      description 'Get paginated list of reviews for a specific company'

      parameter name: :verified_only, in: :query, type: :boolean, required: false,
                description: 'Show only verified reviews'
      parameter name: :min_rating, in: :query, type: :number, required: false,
                description: 'Minimum rating filter (1-5)'
      parameter name: :sort, in: :query, type: :string, required: false,
                description: 'Sort by field (rating, review_date, -rating, -review_date)'
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
                       type: { type: :string, example: 'review' },
                       attributes: {
                         type: :object,
                         properties: {
                           customer_name: { type: :string },
                           rating: { type: :integer },
                           review_text: { type: :string },
                           review_date: { type: :string, format: :date },
                           verified_review: { type: :boolean }
                         }
                       },
                       relationships: { type: :object },
                       links: { type: :object }
                     }
                   }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     rating_distribution: {
                       type: :object,
                       properties: {
                         '5': { type: :integer },
                         '4': { type: :integer },
                         '3': { type: :integer },
                         '2': { type: :integer },
                         '1': { type: :integer }
                       }
                     },
                     pagination: { type: :object }
                   }
                 },
                 links: { type: :object }
               }

        let(:city) { create(:city) }
        let(:company) { create(:company, city: city) }
        let!(:review) { create(:review, company: company) }
        let(:company_id) { company.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_an(Array)
          expect(data['meta']['rating_distribution']).to be_present
        end
      end

      response(404, 'company not found') do
        let(:company_id) { 'invalid' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to be_present
        end
      end
    end
  end
end
