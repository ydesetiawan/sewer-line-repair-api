# frozen_string_literal: true

class GalleryImageSerializer
  include JSONAPI::Serializer

  set_type :gallery_image
  set_id :id

  attributes :title, :description, :position, :image_type

  # Active Storage URLs
  attribute :image_url do |object|
    object.image_url if object.image.attached?
  end

  attribute :thumbnail_url do |object|
    object.thumbnail_url if object.thumbnail.attached? || object.image.attached?
  end

  # Relationships
  belongs_to :company

  # Self link
  link :self do |object|
    "/api/v1/gallery_images/#{object.id}"
  end
end

