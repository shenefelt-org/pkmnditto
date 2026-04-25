class CreateMoves < ActiveRecord::Migration[8.1]
  def change
    create_table :moves do |t|
      t.string :name
      t.string :url
      t.string :type
      t.integer :power
      t.string :short_text
      t.timestamps
    end
  end
end
