module ApplicationHelper
  # Map OpenWeather icon unicode for easy display
  def weather_emoji_for(code)
    case code
    when "01d" then "☀️"   # clear day
    when "01n" then "🌙"   # clear night
    when "02d" then "🌤️"  # few clouds day
    when "02n" then "⛅"   # few clouds night
    when "03d", "03n" then "☁️"   # scattered clouds
    when "04d", "04n" then "🌥️"   # broken clouds
    when "09d", "09n" then "🌧️"   # shower rain
    when "10d", "10n" then "🌦️"   # rain
    when "11d", "11n" then "🌩️"   # thunderstorm
    when "13d", "13n" then "❄️"   # snow
    when "50d", "50n" then "🌫️"   # mist
    else "🌡️"
    end
  end
end
