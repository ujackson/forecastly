Geocoder.configure(
  lookup: :nominatim,
  ip_lookup: :ipinfo_io,
  api_key: ENV.fetch("GEOCODER_KEY", nil),
  http_headers: { "User-Agent" => "Forecastly (ujackson@gmail.com)" },
  cache: Geocoder::CacheStore::Generic.new(Rails.cache, {}),
  cache_options: {
    expiration: 2.days,
    prefix: "geocoder:"
  }
)
