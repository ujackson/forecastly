require "test_helper"

class ForecastsControllerTest < ActionDispatch::IntegrationTest
  include WeatherDataHelper

  setup do
    @inputs = { lat: 33.44, lon: -94.04, zip: 75001 }
    @mock_weather_data = mock_weather_data

    # Clear cache before each test
    Rails.cache.clear
  end

  teardown do
    Current.reset_all
  end

  test "should get index" do
    # Stub set_location to set a valid location
    ApplicationController.any_instance.stubs(:set_location).with do
      Current.location = {
        coordinates: { lat: @inputs[:lat], lon: @inputs[:lon] },
        city: "New York",
        region: "NY",
        timezone: "America/New_York",
        zipcode: @inputs[:zip]
      }
      true
    end

    stub_api_request

    get forecasts_url

    assert_response :success
    # Snapshot test the entire response body
    assert_matches_snapshot response.body, "index_with_weather_data"
  end

  test "should create forecast" do
    ApplicationController.any_instance.stubs(:set_location).with do
      Current.location = {
        coordinates: { lat: @inputs[:lat], lon: @inputs[:lon] },
        city: "New York",
        region: "NY",
        timezone: "America/New_York",
        zipcode: @inputs[:zip]
      }
      true
    end

    stub_api_request

    post forecasts_url, params: {
      forecast: {
        address: "New York, NY, USA",
        coordinates: {
          lat: @inputs[:lat],
          lng: @inputs[:lon]
        }
      }
    }, headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    # Snapshot test the turbo stream response
    assert_matches_snapshot response.body, "create_forecast_success_turbo_stream"
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
      }).to_return(
      status: status,
      body: body.to_json,
      headers: { "Content-Type": "application/json" }
    )
  end
end
