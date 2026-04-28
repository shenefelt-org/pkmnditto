class CreateMoveLearnedBies < ActiveRecord::Migration[8.1]
  def change
    create_table :move_learned_bies do |t|
      t.references :pokemon, null: false, foreign_key: true
      t.references :move, null: false, foreign_key: true

      t.timestamps
    end
  end
end
