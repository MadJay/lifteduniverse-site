class VodCategoryField < ApplicationRecord
  belongs_to :vod_asset
  belongs_to :category_field

end
