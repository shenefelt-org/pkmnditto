class CreateDocs < ActiveRecord::Migration[8.1]
  def change
    create_table :docs do |t|
      t.timestamps
    end
  end
end
