# frozen_string_literal: true

require "test_helper"

class Address::AutocompleteTest < ViewComponent::TestCase
  def test_component_renders
    render_inline(Address::Autocomplete.new(city: "Dallas, TX"))

    assert_component_rendered
    assert_matches_snapshot(rendered_content)
  end
end
