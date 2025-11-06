# frozen_string_literal: true

class StateSerializer
  include JSONAPI::Serializer

  set_type :state
  set_id :id

  attributes :name, :code, :slug

  # Relationships with explicit serializers
  belongs_to :country, serializer: :country

  # Self link
  link :self do |object|
    "/api/v1/states/#{object.id}"
  end
end

