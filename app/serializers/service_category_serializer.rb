class ServiceCategorySerializer
  include JSONAPI::Serializer

  set_type :service_category
  set_id :id

  attributes :name, :slug, :description, :created_at, :updated_at

  link :self do |category|
    "/api/v1/service_categories/#{category.id}"
  end
end
