class GalleryImageSerializer
  include JSONAPI::Serializer

  set_type :gallery_image
  set_id :id

  attributes :image_url, :thumbnail_url, :video_url, :image_datetime_utc, :created_at, :updated_at

  belongs_to :company

  link :self do |gallery_image|
    "/api/v1/companies/#{gallery_image.company_id}/gallery_images/#{gallery_image.id}"
  end
end
