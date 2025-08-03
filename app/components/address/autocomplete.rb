# frozen_string_literal: true

# Address::Autocomplete - City Search Component
#
# ViewComponent for rendering an address autocomplete interface.
# Integrates with Google Places API via Stimulus controller for
# real-time city suggestions and coordinate retrieval.
#
# Object Decomposition:
# - city: String - Initial city value for the input field
# - Stimulus Controller: Handles Google Places API integration
# - UI Elements: Search input, dropdown, clear button
#
# Usage:
#   <%= render Address::Autocomplete.new(city: "New York") %>
#
# JavaScript Integration:
# - Uses components--address--autocomplete Stimulus controller
# - Requires Google Places API key in environment
# - Emits custom events for loading states and selections
#
# Styling:
# - Uses Tailwind CSS classes for responsive design
# - Supports keyboard navigation (arrows, enter, escape)
#
class Address::Autocomplete < ViewComponent::Base
  def initialize(city:)
    @city = city
  end
end
