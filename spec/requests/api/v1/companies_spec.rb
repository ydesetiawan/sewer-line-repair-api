# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/companies', type: :request do
  path '/api/v1/companies/search' do
    get 'Search companies' do
      tags 'Companies'
      produces 'application/vnd.api+json'

      parameter name: :city, in: :query, type: :string, required: false, description: 'City name (e.g., "Orlando")'
      parameter name: :state, in: :query, type: :string, required: false, description: 'State code or name (e.g., "FL" or "Florida")'
      parameter name: :country, in: :query, type: :string, required: false, description: 'Country code (default: "US")'
      parameter name: :address, in: :query, type: :string, required: false, description: 'Full address for proximity search'
      parameter name: :lat, in: :query, type: :number, required: false, description: 'Latitude (use with lng)'
      parameter name: :lng, in: :query, type: :number, required: false, description: 'Longitude (use with lat)'
      parameter name: :radius, in: :query, type: :integer, required: false, description: 'Search radius in miles (default: 25)'
      parameter name: :service_category, in: :query, type: :string, required: false, description: 'Service type slug'
      parameter name: :verified_only, in: :query, type: :boolean, required: false, description: 'Filter verified professionals only'
      parameter name: :min_rating, in: :query, type: :number, required: false, description: 'Minimum rating (0-5)'
      parameter name: :sort, in: :query, type: :string, required: false, description: 'Sort: "rating", "-rating", "distance", "name"'
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number (default: 1)'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Results per page (default: 20, max: 100)'
      parameter name: :include, in: :query, type: :string, required: false, description: 'Include relationships: "city,reviews,service_categories,gallery_images"'

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
                      street_address: { type: :string },
                      zip_code: { type: :string },
                      latitude: { type: :string },
                      longitude: { type: :string },
                      specialty: { type: :string },
                      service_level: { type: :string },
                      description: { type: :string },
                      average_rating: { type: :string },
                      total_reviews: { type: :integer },
                      verified_professional: { type: :boolean },
                      certified_partner: { type: :boolean },
                      licensed: { type: :boolean },
                      insured: { type: :boolean },
                      background_checked: { type: :boolean },
                      service_guarantee: { type: :boolean },
                      distance_miles: { type: :number },
                      distance_kilometers: { type: :number },
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
                      },
                      service_categories: {
                        type: :object,
                        properties: {
                          data: {
                            type: :array,
                            items: {
                              type: :object,
                              properties: {
                                id: { type: :string },
                                type: { type: :string, example: 'service_category' }
                              }
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
              items: {
                type: :object
              }
            },
            meta: {
              type: :object,
              properties: {
                search_context: {
                  type: :object,
                  properties: {
                    query_type: { type: :string },
                    location: { type: :string },
                    coordinates: { type: :object },
                    radius_miles: { type: :integer },
                    filters_applied: { type: :object }
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

        let(:city) { 'Orlando' }
        let(:state) { 'FL' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_an(Array)
        end
      end

      response '404', 'no results found' do
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
                  detail: { type: :string },
                  meta: {
                    type: :object,
                    properties: {
                      suggestions: {
                        type: :array,
                        items: { type: :string }
                      }
                    }
                  }
                }
              }
            }
          }

        let(:city) { 'NonexistentCity' }

        run_test!
      end

      response '400', 'invalid parameters' do
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
                  detail: { type: :string },
                  source: {
                    type: :object,
                    properties: {
                      parameter: { type: :string }
                    }
                  }
                }
              }
            }
          }

        let(:min_rating) { 10 }

        run_test!
      end
    end
  end

  path '/api/v1/companies/{id}' do
    parameter name: :id, in: :path, type: :string, description: 'Company ID'
    parameter name: :include, in: :query, type: :string, required: false,
              description: 'Include relationships: "city,city.state,city.state.country,reviews,service_categories,gallery_images,certifications,service_areas"'

    get 'Retrieves a company' do
      tags 'Companies'
      produces 'application/vnd.api+json'

      response '200', 'company found' do
        schema type: :object,
          properties: {
            data: {
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
                    street_address: { type: :string },
                    zip_code: { type: :string },
                    latitude: { type: :string },
                    longitude: { type: :string },
                    specialty: { type: :string },
                    service_level: { type: :string },
                    description: { type: :string },
                    average_rating: { type: :string },
                    total_reviews: { type: :integer },
                    verified_professional: { type: :boolean },
                    certified_partner: { type: :boolean },
                    licensed: { type: :boolean },
                    insured: { type: :boolean },
                    background_checked: { type: :boolean },
                    service_guarantee: { type: :boolean },
                    created_at: { type: :string, format: 'date-time' },
                    updated_at: { type: :string, format: 'date-time' }
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
            },
            included: {
              type: :array,
              items: { type: :object }
            }
          }

        let(:id) { Company.first.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['id']).to eq(id.to_s)
          expect(data['data']['type']).to eq('company')
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

        let(:id) { 'invalid' }

        run_test!
      end
    end
  end
end

