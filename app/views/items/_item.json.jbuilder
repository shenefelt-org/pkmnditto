json.extract! item, :id, :name, :short_effect, :flavor_text, :sprite, :url, :generations, :created_at, :updated_at
json.url item_url(item, format: :json)
