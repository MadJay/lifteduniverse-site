class Category < ApplicationRecord
  has_many :vod_assets
  has_many :category_fields
end
