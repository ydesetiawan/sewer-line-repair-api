class CitySerializer
  include JSONAPI::Serializer

  set_type :city
  set_id :id

  attributes :name, :slug, :latitude, :longitude, :created_at, :updated_at

  belongs_to :state

  link :self do |city|
    "/api/v1/cities/#{city.id}"
  end
end
