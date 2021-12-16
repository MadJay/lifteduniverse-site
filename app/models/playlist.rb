class Playlist < ApplicationRecord
  has_many :playlist_assets
  has_many :cms_assets, through: :playlist_assets
end
