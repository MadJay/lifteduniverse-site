class CreateCategoryFields < ActiveRecord::Migration[6.1]
  def change
    create_table :category_fields do |t|

      t.timestamps
    end
  end
end
