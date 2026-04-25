class CreateInfoNodes < ActiveRecord::Migration[8.1]
  def change
    create_table :info_nodes do |t|
      t.timestamps
    end
  end
end
