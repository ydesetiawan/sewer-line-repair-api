class CreateGalleryImages < ActiveRecord::Migration[8.1]
  def change
    create_table :gallery_images do |t|
      t.string :company_id, limit: 255, null: false, index: true
      t.string :image_url, null: false
      t.string :thumbnail_url
      t.string :video_url
      t.datetime :image_datetime_utc

      t.timestamps
    end

    add_foreign_key :gallery_images, :companies, column: :company_id, primary_key: :id
  end
end
