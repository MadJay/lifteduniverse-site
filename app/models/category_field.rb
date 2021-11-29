class CategoryField < ApplicationRecord

  belongs_to :category
  has_many :vod_category_fields
  has_many :vod_assets, through: :vod_category_fields

end
