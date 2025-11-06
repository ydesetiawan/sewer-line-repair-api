# frozen_string_literal: true

class CitySerializer
  include JSONAPI::Serializer

  set_type :city
  set_id :id

  attributes :name, :slug, :latitude, :longitude

  # Conditional attribute for company count
  attribute :companies_count, if: proc { |_, params|
    params && params[:include_counts]
  } do |object|
    object.companies.count
  end

  # Relationships with explicit serializers
  belongs_to :state, serializer: :state

  # Meta
  meta do |object, params|
    meta_hash = {}
    if params && params[:include_full_name]
      meta_hash[:full_name] = object.full_name
    end
    meta_hash
  end

  # Self link
  link :self do |object|
    "/api/v1/cities/#{object.id}"
  end
end

