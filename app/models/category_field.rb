class CategoryField < ApplicationRecord
  belongs_to :category
  has_many :assets_category_fields
  has_many :cms_assets, through: :assets_category_fields

end
