class CreateDamageRelations < ActiveRecord::Migration[8.1]
  def change
    create_table :damage_relations do |t|
      t.timestamps
    end
  end
end
