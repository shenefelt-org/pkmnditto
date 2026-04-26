class RemakeTypesTable < ActiveRecord::Migration[8.1]
  def change
    drop_table :types, if_exists: true

    create_table :types do |t|
      t.string :name, index: { unique: true }
      t.string :url, index: { unique: true }
    end

  end
end
