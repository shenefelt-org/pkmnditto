class AddTypeNameToDamageRelations < ActiveRecord::Migration[8.1]
  def change
    add_column :damage_relations, :type_name, :string
  end
end
