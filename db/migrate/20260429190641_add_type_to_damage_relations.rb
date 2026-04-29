class AddTypeToDamageRelations < ActiveRecord::Migration[8.1]
  def change
    add_reference :damage_relations, :type, null: true, foreign_key: true
  end
end
