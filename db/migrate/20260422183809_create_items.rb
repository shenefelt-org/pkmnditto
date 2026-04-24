class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items do |t|
      t.string :name
      t.string :url
      t.string :sprite 
      t.text :generations
      t.string :short_effect
      t.timestamps
    end
  end
end
