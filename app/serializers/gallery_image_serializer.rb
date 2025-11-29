class GalleryImageSerializer
  include JSONAPI::Serializer

  set_type :gallery_image
  set_id :id

  attributes :image_url, :thumbnail_url, :video_url, :image_datetime_utc, :created_at, :updated_at
end
