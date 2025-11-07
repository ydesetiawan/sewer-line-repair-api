class CountrySerializer
  include JSONAPI::Serializer

  set_type :country
  set_id :id

  attributes :name, :code, :slug, :created_at, :updated_at

  has_many :states

  link :self do |country|
    "/api/v1/countries/#{country.id}"
  end
end
