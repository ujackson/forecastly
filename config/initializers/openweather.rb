Rails.configuration.openweather = {
  api_key: ENV.fetch("OPENWEATHER_API_KEY", nil),
  endpoint: "https://api.openweathermap.org"
}
