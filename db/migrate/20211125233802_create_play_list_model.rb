class CreatePlayListModel < ActiveRecord::Migration[6.1]
  def change
    create_table :vod_asset do |t|
      t.string :name
      t.text :description
      t.integer :customer_id
      t.integer :category_id
      t.integer :status_id
      t.boolean :is_published
      t.timestamps
    end
  end
end
