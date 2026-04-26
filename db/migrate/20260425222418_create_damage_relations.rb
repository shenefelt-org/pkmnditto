class CreateDamageRelations < ActiveRecord::Migration[8.1]
  def change
    create_table :damage_relations do |t|
      t.timestamps
      t.text :no_damage_to
      t.text :half_damage_to
      t.text :double_damage_to
      t.text :no_damage_from
      t.text :half_damage_from
      t.text :double_damage_from
    end
  end
end
