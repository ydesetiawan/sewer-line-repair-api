# frozen_string_literal: true

class ServiceCategorySerializer
  include JSONAPI::Serializer

  set_type :service_category
  set_id :id

  attributes :name, :slug, :description

  # Relationships
  has_many :companies

  # Self link
  link :self do |object|
    "/api/v1/service_categories/#{object.id}"
  end
end
# frozen_string_literal: true

class StateSerializer
  include JSONAPI::Serializer

  set_type :state
  set_id :id

  attributes :name, :code, :slug

  # Relationships
  belongs_to :country
  has_many :cities

  # Self link
  link :self do |object|
    "/api/v1/states/#{object.id}"
  end
end
