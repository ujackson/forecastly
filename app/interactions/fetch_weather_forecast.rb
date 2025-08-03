# frozen_string_literal: true

# FetchWeatherForecast - Weather Data Retrieval Interaction
#
# This interaction handles fetching weather forecast data from the OpenWeather API.
# It implements caching, error handling, and data validation for weather requests.
#
# Object Decomposition:
# - Coordinates (lat, lon): Geographic location for weather lookup
# - ZIP Code: Used for caching key and location context
# - API Configuration: Endpoint and authentication
# - Cache Layer: 30-minute TTL for reducing API calls
# - Error Handling: Graceful degradation on API failures
#
# Usage:
#   outcome = FetchWeatherForecast.run(lat: 40.7128, lon: -74.0060, zip: 10001)
#   if outcome.valid?
#     weather_data = outcome.result
#   else
#     errors = outcome.errors
#   end
#
# Dependencies:
# - OpenWeather API (requires API key)
# - Rails.cache for result caching
# - HTTP gem for API requests
#
class FetchWeatherForecast < ActiveInteraction::Base
  decimal :lat
  decimal :lon
  integer :zip
  string :api_key, default: -> { Rails.configuration.openweather[:api_key] }
  string :endpoint, default: -> { Rails.configuration.openweather[:endpoint] }

  validates :lat, :lon, :zip, :api_key, :endpoint, presence: true
  validates :lat, :lon, :zip, numericality: true

  def execute
    forecast_data = fetch_cached_forecast
    errors.add(:base, "Unable to retrieve weather information.") unless forecast_data.present?

    forecast_data
  rescue StandardError => e
    handle_error(e)
  end

  private

  def fetch_cached_forecast
    Rails.cache.fetch(cache_key, expires_in: 30.minutes, skip_nil: true) do
      get_weather_forecast
    end
  end

  def get_weather_forecast
    params = {
      lat: lat,
      lon: lon,
      units: "imperial",
      exclude: "minutely,alerts",
      appid: api_key
    }

    response = HTTP.get("#{endpoint}/data/3.0/onecall", params: params)
    return unless response.status.success?

    parsed_response(response)
  rescue HTTP::Error, JSON::ParserError => e
    handle_error(e)
    nil
  end

  def parsed_response(response)
    body = response.body.to_s.strip
    parsed_body = JSON.parse(body)
    parsed_body.deep_symbolize_keys
  end

  def cache_key
    "zipcode_#{zip}"
  end

  def handle_error(error)
    Rails.logger.error error.message
    errors.add(:base, "Unable to retrieve weather information: #{error.message}")
  end
end
