# frozen_string_literal: true

class Weather::PredictionCard < ViewComponent::Base
  include ApplicationHelper

  def initialize(forecast:)
    @forecast = forecast
  end

  # calculate high / low percentage
  def percentage(current_temp, low_temp, high_temp)
    return 0 if high_temp == low_temp

    ((current_temp - low_temp) / (high_temp - low_temp).to_f * 100).round
  end
end
