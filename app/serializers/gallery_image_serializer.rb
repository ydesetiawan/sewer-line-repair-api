class GalleryImageSerializer
  include JSONAPI::Serializer

  set_type :gallery_image
  set_id :id

  attributes :title, :description, :position, :image_type, :created_at, :updated_at

  attribute :image_url do |gallery_image|
    if gallery_image.image.attached?
      Rails.application.routes.url_helpers.rails_blob_url(gallery_image.image, only_path: true)
    end
  end

  attribute :image_thumbnail_url do |gallery_image|
    if gallery_image.image.attached?
      Rails.application.routes.url_helpers.rails_representation_url(
        gallery_image.image.variant(resize_to_limit: [300, 300]),
        only_path: true
      )
    end
  end

  belongs_to :company

  link :self do |gallery_image|
    "/api/v1/companies/#{gallery_image.company_id}/gallery_images/#{gallery_image.id}"
  end
end
