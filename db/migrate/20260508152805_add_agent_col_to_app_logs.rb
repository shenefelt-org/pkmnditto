class AddAgentColToAppLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :app_logs, :agent, :string
  end
end
