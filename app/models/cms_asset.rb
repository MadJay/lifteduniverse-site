class CmsAsset < ApplicationRecord
  before_create :create_uid

  belongs_to :account, optional: true #TODO - Remove this when Accounts are implemented
  belongs_to :category, optional: true
  has_many :cms_category_fields
  has_many :category_fields, through: :cms_category_fields

  # Validations ------------------------------------------------/
  validates :title, presence: true
  validates_uniqueness_of :uid

  # Scopes  ------------------------------------------------/
  default_scope {where(is_archived: false)}

  private
    def create_uid
      self.uid = generate_uid
    end

    def generate_uid
      loop do
        token = SecureRandom.alphanumeric(8)
        break token unless CmsAsset.where(uid: token).exists?
      end
    end
end