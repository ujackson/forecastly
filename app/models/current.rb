# Current - Request-Scoped Location Attributes
#
# Implements Rails CurrentAttributes pattern to store location data
# that persists across the request lifecycle. Automatically manages
# timezone setting based on location data.
#
# Object Decomposition:
# - location: Hash containing coordinates, city, region, timezone, zipcode
#   - coordinates: { lat: Float, lon: Float }
#   - city: String (e.g., "New York")
#   - region: String (e.g., "NY")
#   - timezone: String (e.g., "America/New_York")
#   - zipcode: Integer (e.g., 10001)
#
# Automatic Behaviors:
# - Sets Time.zone when location with timezone is assigned
# - Resets timezone on request completion
#
# Usage:
#   Current.location = {
#     coordinates: { lat: 40.7128, lon: -74.0060 },
#     city: "New York",
#     region: "NY",
#     timezone: "America/New_York",
#     zipcode: 10001
#   }
#
class Current < ActiveSupport::CurrentAttributes
  attribute :location

  resets { Time.zone = nil }

  def location=(value)
    super(value)

    Time.zone = value[:timezone] if value.is_a?(Hash) && value[:timezone].present?
  end
end
