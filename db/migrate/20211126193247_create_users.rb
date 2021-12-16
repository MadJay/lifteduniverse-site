class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :profiles do |t|
      t.string :uid
      t.integer :account_id
      t.timestamps
    end
  end
end
