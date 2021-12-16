class Category < ApplicationRecord
  has_many :cms_assets
  has_many :category_fields
end
