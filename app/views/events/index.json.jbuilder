json.array!(@events) do |event|
  json.extract! event, :id, :name, :start_date, :occurence_frequency, :delivery_date
  json.url event_url(event, format: :json)
end
