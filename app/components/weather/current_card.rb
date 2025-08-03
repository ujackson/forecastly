# frozen_string_literal: true

# Weather::CurrentCard - Current Weather Display Component
#
# ViewComponent for rendering current weather conditions including
# temperature, humidity, wind speed, and visibility information.
#
# Object Decomposition:
# - forecast: Hash containing current weather data from OpenWeather API
#   - current: Hash with temperature, humidity, wind_speed, visibility
#   - location: String or derived from Current.location
#
# Data Requirements:
# - forecast[:current][:temp] - Temperature in Fahrenheit
# - forecast[:current][:humidity] - Humidity percentage
# - forecast[:current][:wind_speed] - Wind speed in mph
# - forecast[:current][:visibility] - Visibility in meters
#
# Helper Methods:
# - meters_to_miles: Converts visibility from meters to miles
# - location: Returns display location string
#
# Usage:
#   <%= render Weather::CurrentCard.new(forecast: @forecast_data) %>
#
class Weather::CurrentCard < ViewComponent::Base
  def initialize(forecast:)
    @forecast = forecast
  end

  def meters_to_miles(meters)
    meters.to_f / 1609.344
  end

  def location
    params[:address].presence || "#{Current.location[:city]}, #{Current.location[:region]}"
  end
end
