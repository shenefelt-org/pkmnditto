class CreateAppLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :app_logs do |t|
      t.string :level
      t.text :message
      t.string :ip_address
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
  end
end
