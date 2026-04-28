class AddLearnedByToMoves < ActiveRecord::Migration[8.1]
  def change
    add_reference :moves, :pokemon, null: false, foreign_key: true
  end
end
