# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/locations', type: :request do
  path '/api/v1/locations/autocomplete' do
    get 'Location autocomplete search' do
      tags 'Locations'
      produces 'application/vnd.api+json'

      parameter name: :q, in: :query, type: :string, required: true, description: 'Search query (min 2 chars)'
      parameter name: :type, in: :query, type: :string, required: false, description: 'Filter: "city", "state", "country"'
      parameter name: :limit, in: :query, type: :integer, required: false, description: 'Max results (default: 10)'

      response '200', 'locations found' do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :string },
                  type: { type: :string, example: 'city' },
                  attributes: {
                    type: :object,
                    properties: {
                      name: { type: :string },
                      slug: { type: :string },
                      latitude: { type: :string },
                      longitude: { type: :string },
                      companies_count: { type: :integer }
                    }
                  },
                  relationships: {
                    type: :object,
                    properties: {
                      state: {
                        type: :object,
                        properties: {
                          data: {
                            type: :object,
                            properties: {
                              id: { type: :string },
                              type: { type: :string, example: 'state' }
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
                  },
                  meta: {
                    type: :object,
                    properties: {
                      full_name: { type: :string }
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
                query: { type: :string },
                total_results: { type: :integer }
              }
            }
          }

        let(:q) { 'orla' }
        let(:type) { 'city' }
        let(:limit) { 5 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_an(Array)
          expect(data['meta']).to have_key('query')
          expect(data['meta']['query']).to eq('orla')
        end
      end

      response '400', 'invalid query' do
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

        let(:q) { 'a' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to be_an(Array)
          expect(data['errors'].first['detail']).to include('at least 2 characters')
        end
      end
    end
  end

  path '/api/v1/locations/geocode' do
    post 'Geocode an address' do
      tags 'Locations'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: :geocode_request, in: :body, schema: {
        type: :object,
        properties: {
          data: {
            type: :object,
            properties: {
              type: { type: :string, example: 'geocode_request' },
              attributes: {
                type: :object,
                properties: {
                  address: { type: :string, example: '222 Orange Ave, Orlando, FL 32801' }
                },
                required: ['address']
              }
            },
            required: ['type', 'attributes']
          }
        },
        required: ['data']
      }

      response '200', 'address geocoded' do
        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                id: { type: :string },
                type: { type: :string, example: 'geocode_result' },
                attributes: {
                  type: :object,
                  properties: {
                    formatted_address: { type: :string },
                    street_address: { type: :string },
                    zip_code: { type: :string },
                    latitude: { type: :string },
                    longitude: { type: :string }
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
                    state: {
                      type: :object,
                      properties: {
                        data: {
                          type: :object,
                          properties: {
                            id: { type: :string },
                            type: { type: :string, example: 'state' }
                          }
                        }
                      }
                    },
                    country: {
                      type: :object,
                      properties: {
                        data: {
                          type: :object,
                          properties: {
                            id: { type: :string },
                            type: { type: :string, example: 'country' }
                          }
                        }
                      }
                    }
                  }
                },
                meta: {
                  type: :object,
                  properties: {
                    nearby_companies_count: { type: :integer }
                  }
                }
              }
            },
            included: {
              type: :array,
              items: { type: :object }
            }
          }

        let(:geocode_request) do
          {
            data: {
              type: 'geocode_request',
              attributes: {
                address: '222 Orange Ave, Orlando, FL 32801'
              }
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['type']).to eq('geocode_result')
          expect(data['data']['attributes']).to have_key('latitude')
          expect(data['data']['attributes']).to have_key('longitude')
        end
      end

      response '422', 'geocoding failed' do
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
                      pointer: { type: :string }
                    }
                  },
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

        let(:geocode_request) do
          {
            data: {
              type: 'geocode_request',
              attributes: {
                address: 'InvalidAddressThatDoesNotExist123456789'
              }
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to be_an(Array)
          expect(data['errors'].first['code']).to eq('geocoding_failed')
        end
      end

      response '422', 'validation error - missing address' do
        let(:geocode_request) do
          {
            data: {
              type: 'geocode_request',
              attributes: {}
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to be_an(Array)
          expect(data['errors'].first['code']).to eq('validation_error')
        end
      end
    end
  end
end

