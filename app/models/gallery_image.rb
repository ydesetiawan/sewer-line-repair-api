class GalleryImage < ApplicationRecord
  # Associations
  belongs_to :company

  # Validations
  validates :image_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }
  validates :thumbnail_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }
  validates :video_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }

  # Scopes
  scope :images, -> { where.not(image_url: nil) }
  scope :videos, -> { where.not(video_url: nil) }
  scope :recent, -> { order(image_datetime_utc: :desc) }
end
