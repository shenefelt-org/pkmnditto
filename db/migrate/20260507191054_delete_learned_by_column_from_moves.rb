class DeleteLearnedByColumnFromMoves < ActiveRecord::Migration[8.1]
  def change
    remove_column :moves, :learned_by
  end
end
