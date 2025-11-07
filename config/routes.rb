Rails.application.routes.draw do
  # Swagger API Documentation
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # Health check
  get 'up' => 'rails/health#show', :as => :rails_health_check

  # API v1 Routes (JSON:API format)
  namespace :api do
    namespace :v1 do
      # Company search and details
      get 'companies/search', to: 'companies#search'
      resources :companies, only: [:show] do
        # Nested routes for company relationships
        resources :reviews, only: [:index]
        resources :gallery_images, only: [:index]
      end

      # States with nested companies
      get 'states/:state_slug/companies', to: 'states#companies'

      # Location services
      get 'locations/autocomplete', to: 'locations#autocomplete'
      post 'locations/geocode', to: 'locations#geocode'

      # Service categories
      resources :service_categories, only: %i[index show] do
        get 'companies', to: 'service_categories#companies', on: :member
      end

      # Countries, States, Cities (read-only)
      resources :countries, only: %i[index show] do
        resources :states, only: [:index]
      end

      resources :states, only: [:show] do
        resources :cities, only: [:index]
      end

      resources :cities, only: [:show] do
        resources :companies, only: [:index]
      end
    end
  end
end
