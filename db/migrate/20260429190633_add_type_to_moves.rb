class AddTypeToMoves < ActiveRecord::Migration[8.1]
  def change
    add_reference :moves, :type, null: true, foreign_key: true
  end
end
