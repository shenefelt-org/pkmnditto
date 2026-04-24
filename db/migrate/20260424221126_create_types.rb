class CreateTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :types do |t|
      t.integer :type_id
      t.text :type_name

      t.timestamps
    end
  end
end
