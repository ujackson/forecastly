# frozen_string_literal: true

class Weather::OutlookCard < ViewComponent::Base
  include ApplicationHelper

  def initialize(forecast:)
    @forecast = forecast
  end
end
