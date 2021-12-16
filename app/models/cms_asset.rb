class CmsAsset < ActiveRecord
  belongs_to :customer
  belongs_to :category
  has_many :category_fields, through: :category
  has_many :cms_category_fields
end