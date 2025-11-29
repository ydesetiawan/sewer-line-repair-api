require 'swagger_helper'

RSpec.describe 'api/v1/reviews' do
  path '/api/v1/companies/{company_id}/reviews' do
    parameter name: 'company_id', in: :path, type: :string, description: 'Company ID'

    get('List company reviews') do
      tags 'Reviews'
      produces 'application/json'
      description 'Get paginated list of reviews for a specific company'

      parameter name: :min_rating, in: :query, type: :number, required: false,
                description: 'Minimum rating filter (1-5)'
      parameter name: :sort, in: :query, type: :string, required: false,
                description: 'Sort by field (review_rating, review_datetime_utc, -review_rating, -review_datetime_utc)'
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
                           author_title: { type: :string },
                           author_image: { type: :string },
                           review_rating: { type: :integer },
                           review_text: { type: :string },
                           review_datetime_utc: { type: :string, format: :datetime },
                           review_link: { type: :string },
                           review_img_urls: { type: :array, items: { type: :string } },
                           owner_answer: { type: :string },
                           owner_answer_timestamp_datetime_utc: { type: :string, format: :datetime }
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
        let(:review) { create(:review, company: company) }
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
