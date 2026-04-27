class CreateDocs < ActiveRecord::Migration[8.1]
  def change
    create_table :docs do |t|
      t.string :name, index: { unique: true }
      t.string :permalink
      t.text :content
      t.timestamps
    end
  end
end
