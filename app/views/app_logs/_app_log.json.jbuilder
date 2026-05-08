json.extract! app_log, :id, :level, :message, :ip_address, :user_id, :created_at, :updated_at
json.url app_log_url(app_log, format: :json)
