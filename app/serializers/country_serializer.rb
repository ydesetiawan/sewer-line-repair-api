# frozen_string_literal: true

class CountrySerializer
  include JSONAPI::Serializer

  set_type :country
  set_id :id

  attributes :name, :code, :slug

  # Self link
  link :self do |object|
    "/api/v1/countries/#{object.id}"
  end
end
