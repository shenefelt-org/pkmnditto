class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :sub
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :profile_image_url

      t.timestamps
    end
    add_index :users, :sub, unique: true
  end
end
