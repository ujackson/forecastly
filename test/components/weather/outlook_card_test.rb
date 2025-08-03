# frozen_string_literal: true

require "test_helper"

class Weather::OutlookCardTest < ViewComponent::TestCase
  include WeatherDataHelper

  def test_component_renders
    forecast_data = mock_weather_data.deep_symbolize_keys

    render_inline(Weather::OutlookCard.new(forecast: forecast_data[:hourly]))

    assert_component_rendered
    assert_matches_snapshot(rendered_content)
  end
end
