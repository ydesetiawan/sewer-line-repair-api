class GalleryImageSerializer
  include JSONAPI::Serializer

  set_type :gallery_image
  set_id :id

  attributes :title, :description, :position, :image_type, :created_at, :updated_at

  belongs_to :company

  link :self do |gallery_image|
    "/api/v1/companies/#{gallery_image.company_id}/gallery_images/#{gallery_image.id}"
  end
end
