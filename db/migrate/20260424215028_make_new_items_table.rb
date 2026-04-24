class MakeNewItemsTable < ActiveRecord::Migration[8.1]
  def change
    # delete teh curr items table
    drop_table :items, if_exists: true

    create_table :items do |t|
      t.string :name
      t.string :url
      t.string :sprite
      t.text :generations # sereilze in model to keep array
      t.string :flavor_text
      t.string :short_effect

      t.timestamps
    end
  end
end
