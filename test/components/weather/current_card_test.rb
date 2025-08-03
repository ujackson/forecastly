# frozen_string_literal: true

require "test_helper"

class Weather::CurrentCardTest < ViewComponent::TestCase
  include WeatherDataHelper

  def test_component_renders
    Current.location = { city: "New York", region: "NY" }
    data = mock_weather_data.deep_symbolize_keys
    current = data[:current].merge(high: 96, low: 87)

    render_inline(Weather::CurrentCard.new(forecast: current))

    assert_component_rendered
    assert_matches_snapshot(rendered_content)
  end
end
