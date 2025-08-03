require "test_helper"

class FetchWeatherForecastTest < ActiveSupport::TestCase
  include WeatherDataHelper

  def setup
    @inputs = { lat: 33.44, lon: -94.04, zip: 75001 }
    @mock_weather_data = mock_weather_data

    # Clear cache before each test
    Rails.cache.clear
  end

  test "successfully fetches and returns weather data" do
    stub_api_request

    outcome = FetchWeatherForecast.run(@inputs)

    assert outcome.valid?, "Expected valid outcome, got errors: #{outcome.errors.full_messages}"
    assert_not_nil outcome.result

    result = outcome.result
    assert_equal 33.44, result[:lat]
    assert_equal(-94.04, result[:lon])
    assert_equal "America/Chicago", result[:timezone]
    assert_includes result.keys, :current
    assert_includes result.keys, :hourly
    assert_includes result.keys, :daily
    assert_includes result.keys, :alerts
  end

  test "validates presence of required inputs" do
    outcome = FetchWeatherForecast.run({})

    assert_not outcome.valid?
    assert_includes outcome.errors[:lat], "is required"
    assert_includes outcome.errors[:lon], "is required"
    assert_includes outcome.errors[:zip], "is required"
  end

  test "validates numerical format of coordinates and zip" do
    outcome = FetchWeatherForecast.run(lat: "invalid", lon: "invalid", zip: "invalid")

    assert_not outcome.valid?
    assert_includes outcome.errors[:lat], "is not a valid decimal"
    assert_includes outcome.errors[:lon], "is not a valid decimal"
    assert_includes outcome.errors[:zip], "is not a valid integer"
  end

  test "caches successful API responses" do
    stub_api_request

    # First request should hit the API
    outcome1 = FetchWeatherForecast.run(@inputs)
    assert outcome1.valid?

    # Second request should hit cache
    outcome2 = FetchWeatherForecast.run(@inputs)
    assert outcome2.valid?
    assert_equal outcome1.result, outcome2.result

    # Verify cache key
    cache_key = "zipcode_#{@inputs[:zip]}"
    cached_data = Rails.cache.read(cache_key)

    assert Rails.cache.exist?(cache_key)
    assert_not_nil cached_data
    assert_equal outcome1.result, cached_data
  end

  test "skips cache for nil responses" do
    # Stub API to return nil (simulating an error)
    stub_api_request(status: 500, body: { error: "Internal Server Error" })

    outcome = FetchWeatherForecast.run(@inputs)

    assert_not outcome.valid?

    # Verify nothing was cached
    cache_key = "zipcode_#{@inputs[:zip]}"
    assert_nil Rails.cache.read(cache_key)
  end

  test "handles HTTP errors" do
    stub_api_request(status: 500, body: { error: "Internal Server Error" })

    outcome = FetchWeatherForecast.run(@inputs)

    assert_not outcome.valid?
    assert_includes outcome.errors[:base], "Unable to retrieve weather information."
  end

  test "cache expires after 30 minutes" do
    stub_api_request

    # First request
    outcome1 = FetchWeatherForecast.run(@inputs)
    assert outcome1.valid?

    # Manually expire cache
    cache_key = "zipcode_#{@inputs[:zip]}"
    Rails.cache.delete(cache_key)

    # Stub a different response for second request
    stub_api_request body: mock_weather_data(lat: 47.751076, lon: -120.740135)

    # Second request should get new data
    outcome2 = FetchWeatherForecast.run(@inputs)
    assert outcome2.valid?
    assert_not_equal outcome1.result[:lat], outcome2.result[:lat]
  end

  test "deep symbolizes response keys" do
    stub_api_request

    outcome = FetchWeatherForecast.run(@inputs)

    assert outcome.valid?
    result = outcome.result

    # Verify all keys are symbols
    assert result.keys.all? { |key| key.is_a?(Symbol) }
    assert result[:current].keys.all? { |key| key.is_a?(Symbol) }
    assert result[:hourly].first.keys.all? { |key| key.is_a?(Symbol) }
    assert result[:daily].first.keys.all? { |key| key.is_a?(Symbol) }
    assert result[:alerts].first.keys.all? { |key| key.is_a?(Symbol) }
  end

  private

  def stub_api_request(status: 200, body: @mock_weather_data)
    endpoint = "#{Rails.configuration.openweather[:endpoint]}/data/3.0/onecall"
    params = {
      lat: @inputs[:lat],
      lon: @inputs[:lon],
      units: "imperial",
      exclude: "minutely,alerts",
      appid: Rails.configuration.openweather[:api_key]
    }

    query_string = params.map { |k, v| "#{k}=#{v}" }.join("&")
    api_url = "#{endpoint}?#{query_string}"

    stub_request(:get, api_url).with(
      headers: {
        "Connection"=>"close",
        "Host"=>"api.openweathermap.org",
        "User-Agent"=>"http.rb/5.3.1"
      })
      .to_return(
        status: status,
        body: body.to_json,
        headers: { "Content-Type": "application/json" }
      )
  end
end
