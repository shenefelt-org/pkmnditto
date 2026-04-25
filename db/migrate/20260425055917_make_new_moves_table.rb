class MakeNewMovesTable < ActiveRecord::Migration[8.1]
  def change
    drop_table :moves, if_exists: true
    create_table :moves do |t|
      t.string :name
      t.string :url
      t.string :move_type
      t.integer :power
      t.string :short_text
      t.timestamps
    end

  end
end
