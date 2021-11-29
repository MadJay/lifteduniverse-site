class VodAsset < ActiveRecord

  belongs_to :customer
  belongs_to :category
  has_many :category_fields, through: :category
  has_many :vod_category_fields
end