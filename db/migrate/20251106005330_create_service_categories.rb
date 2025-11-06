class CreateServiceCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :service_categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description

      t.timestamps
    end

    add_index :service_categories, :slug, unique: true
  end
end
