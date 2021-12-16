class CreateCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :categories do |t|
      t.string :title
      t.string :description
      t.timestamps
    end

    create_table :category_fields do |t|
      t.integer :category_id
      t.timestamps
    end

    create_table :asset_category_fields do |t|
      t.integer :category_field_id
      t.integer :cms_asset_id
      t.timestamps
    end

  end
end
