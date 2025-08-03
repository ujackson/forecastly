class ForecastsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { head :too_many_requests }

  # GET /forecasts
  def index
    location = Current.location

    @forecast_data = FetchWeatherForecast.run!(
      lat: location[:coordinates][:lat],
      lon: location[:coordinates][:lon],
      zip: location[:zipcode]
    )

  rescue => e
    # Ignored
  end

  # POST /forecasts
  def create
    coords = forecast_params[:coordinates]
    outcome = FetchWeatherForecast.run(lat: coords[:lat], lon: coords[:lng], zip: Current.location[:zipcode])

    if outcome.valid?
      render turbo_stream: turbo_stream.update("forecast", partial: "forecast", locals: { data: outcome.result })
    else
      html = ApplicationController.render(Ui::Flash.new(message: outcome.errors.full_messages.to_sentence, type: :error), layout: false)
      render turbo_stream: turbo_stream.update("flash", html: html)
    end
  end

  private

  def forecast_params
    params.expect(forecast: [ :address, { coordinates: [ :lat, :lng ] } ])
  end
end
