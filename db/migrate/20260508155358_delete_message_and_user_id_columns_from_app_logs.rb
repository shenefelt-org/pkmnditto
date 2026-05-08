class DeleteMessageAndUserIdColumnsFromAppLogs < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :app_logs, :users
    remove_column :app_logs, :user_id, :bigint
    remove_column :app_logs, :message, :string
  end
end
