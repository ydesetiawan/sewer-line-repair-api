class GalleryImage < ApplicationRecord
  # Associations
  belongs_to :company

  # Validations
  validates :image_url, presence: true
  validates :image_type, inclusion: { in: %w[before after work team equipment] }, allow_nil: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }

  # Default scope
  default_scope { order(position: :asc) }

  # Scopes
  scope :by_type, ->(type) { where(image_type: type) }

  # Callbacks
  before_create :set_default_position

  private

  def set_default_position
    if position.nil? || position.zero?
      max_position = company.gallery_images.maximum(:position) || 0
      self.position = max_position + 1
    end
  end
end
