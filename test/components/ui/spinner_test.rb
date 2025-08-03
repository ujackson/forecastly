# frozen_string_literal: true

require "test_helper"

class Ui::SpinnerTest < ViewComponent::TestCase
  def test_component_renders
    render_inline(Ui::Spinner.new)

    assert_component_rendered
    assert_selector "div[data-controller='components--ui--spinner']"
    assert_selector("div", id: "overlay")
    assert_selector("div", id: "waitSpinner")
  end
end
