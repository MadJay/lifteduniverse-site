class AssetsCategoryField < ApplicationRecord
  belongs_to :cms_asset
  belongs_to :category_field
end
