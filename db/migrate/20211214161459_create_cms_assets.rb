class CreateCmsAssets < ActiveRecord::Migration[6.1]
  def change
    create_table :cms_assets do |t|
      t.string :name
      t.text :description
      t.integer :account_id
      t.integer :category_id
      t.integer :status_id
      t.boolean :is_published
      t.string :vod_streams_uid
      t.string :recording_uid
      t.string :transcoder_uid
      t.string :state
      t.string :uid
      t.timestamps
    end

    create_table :playlists do |t|
      t.string :title
      t.integer :user_id
      t.timestamps
    end

    create_table :playlist_assets do |t|
      t.integer :playlist_id
      t.integer :cms_asset_id
      t.integer :order
      t.timestamps
    end

    add_index :playlist_assets, :playlist_id
    add_index :playlist_assets, :cms_asset_id
    add_index :cms_assets, :id
    add_index :cms_assets, :uid
  end
end
