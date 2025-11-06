class CreateGalleryImages < ActiveRecord::Migration[8.1]
  def change
    create_table :gallery_images do |t|
      t.references :company, null: false, foreign_key: true, index: true
      t.string :title
      t.text :description
      t.string :image_url, null: false
      t.string :thumbnail_url
      t.integer :position, default: 0, null: false
      t.string :image_type

      t.timestamps
    end

    add_index :gallery_images, [:company_id, :position]
    add_index :gallery_images, :image_type
  end
end
