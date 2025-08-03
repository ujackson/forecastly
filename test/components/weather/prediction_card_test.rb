# frozen_string_literal: true

require "test_helper"

class Weather::PredictionCardTest < ViewComponent::TestCase
  include WeatherDataHelper

  def test_component_renders
    forecast_data = mock_weather_data.deep_symbolize_keys

    render_inline(Weather::PredictionCard.new(forecast: forecast_data[:daily]))

    assert_component_rendered
    assert_matches_snapshot(rendered_content)
  end
end
