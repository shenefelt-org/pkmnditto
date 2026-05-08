class AddRequestMethodAndPathToAppLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :app_logs, :method, :string
    add_column :app_logs, :path, :string
  end
end
