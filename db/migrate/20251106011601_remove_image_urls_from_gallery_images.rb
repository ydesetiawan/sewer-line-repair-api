class RemoveImageUrlsFromGalleryImages < ActiveRecord::Migration[8.1]
  def change
    remove_column :gallery_images, :image_url, :string
    remove_column :gallery_images, :thumbnail_url, :string
  end
end

