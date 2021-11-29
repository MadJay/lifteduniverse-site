class CreateVodCategoryFields < ActiveRecord::Migration[6.1]
  def change
    create_table :vod_category_fields do |t|

      t.timestamps
    end
  end
end
