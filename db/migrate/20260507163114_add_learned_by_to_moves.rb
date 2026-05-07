class AddLearnedByToMoves < ActiveRecord::Migration[8.1]
  def change
    add_column :moves, :learned_by, :text
  end
end
