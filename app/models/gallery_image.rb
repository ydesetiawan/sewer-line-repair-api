class GalleryImage < ApplicationRecord
  # Associations
  belongs_to :company

  # Active Storage attachments
  has_one_attached :image
  has_one_attached :thumbnail

  # Validations
  validates :image, presence: true
  validates :image_type, inclusion: { in: %w[before after work team equipment] }, allow_nil: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }

  # Active Storage validations (file type and size)
  validate :acceptable_image_format
  validate :acceptable_image_size

  # Default scope
  default_scope { order(position: :asc) }

  # Scopes
  scope :by_type, ->(type) { where(image_type: type) }

  # Callbacks
  before_create :set_default_position

  # Helper methods for image URLs
  def image_url
    return nil unless image.attached?
    Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true)
  end

  def thumbnail_url
    return nil unless thumbnail.attached?
    Rails.application.routes.url_helpers.rails_blob_url(thumbnail, only_path: true)
  end

  # Generate thumbnail variant on-the-fly
  def thumbnail_variant
    return nil unless image.attached?
    image.variant(resize_to_limit: [200, 150])
  end

  # Large image variant
  def large_variant
    return nil unless image.attached?
    image.variant(resize_to_limit: [800, 600])
  end

  private

  def set_default_position
    if position.nil? || position.zero?
      max_position = company.gallery_images.unscoped.maximum(:position) || 0
      self.position = max_position + 1
    end
  end

  def acceptable_image_format
    return unless image.attached?

    acceptable_types = ["image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"]
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, "must be a JPEG, PNG, GIF, or WebP")
    end
  end

  def acceptable_image_size
    return unless image.attached?

    # 10 MB limit
    max_size = 10.megabytes
    if image.byte_size > max_size
      errors.add(:image, "is too large (maximum is #{max_size / 1.megabyte}MB)")
    end
  end
end
