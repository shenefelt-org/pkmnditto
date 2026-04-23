class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items do |t|
      t.integer :item_num
      t.string :name
      t.string :url 
      t.string :default_sprite_url
      t.timestamps
    end
  end
end
