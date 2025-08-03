class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_location

  private

  # Automatically set user location based on address from the search input or IP address
  def set_location
    ip = Rails.env.development? ? "8.8.8.8" : request.remote_ip
    address = params[:address].presence
    query = address || ip
    Current.location = detect_location(query, address.present?)
  end

  def detect_location(query, is_address = false)
    # Geocode user address or user IP
    loc_data = Geocoder.search(query).first&.data&.transform_keys(&:to_sym)
    is_address ? location_data_by_address(loc_data) : location_data_by_ip(loc_data)
  rescue => e
    Rails.logger.error e
    {}
  end

  def location_data_by_ip(data)
    lat, lng = data&.dig(:loc)&.split(",")&.map(&:to_f)

    {
      zipcode: data&.dig(:postal)&.to_i,
      coordinates: { lat: lat, lon: lng },
      city: data&.dig(:city),
      region: data&.dig(:region),
      country: data&.dig(:country),
      timezone: data&.dig(:timezone)
    }
  end

  def location_data_by_address(data)
    result = Geocoder.search([ data[:lat].to_f, data[:lon].to_f ]).first
    return {} unless result

    address = result.data["address"] || {}

    {
      zipcode: address["postcode"]&.to_i,
      coordinates: { lat: result.latitude.to_f, lon: result.longitude.to_f },
      city: address["village"] || address["town"] || address["city"],
      region: address["county"],
      country: address["country_code"]&.upcase,
      timezone: zip_timezone(address["postcode"])
    }
  end

  def zip_timezone(zip_code)
    z = Ziptz.new
    z.time_zone_name(zip_code)
  end
end
