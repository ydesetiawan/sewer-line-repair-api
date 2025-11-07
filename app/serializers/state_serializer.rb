class StateSerializer
  include JSONAPI::Serializer

  set_type :state
  set_id :id

  attributes :name, :code, :slug, :created_at, :updated_at

  belongs_to :country
  has_many :cities

  link :self do |state|
    "/api/v1/states/#{state.id}"
  end
end
