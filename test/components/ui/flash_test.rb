# frozen_string_literal: true

require "test_helper"

class Ui::FlashTest < ViewComponent::TestCase
  def test_render_success_component
    render_inline(Ui::Flash.new(message: "hello world", type: "success"))

    assert_component_rendered
    assert_selector("div", class: "rounded-md bg-green-50 p-4")
    assert_selector("p", class: "text-sm font-medium")
    assert_selector("button", class: "inline-flex rounded-md bg-green-50 p-1.5 text-green-500 hover:bg-green-100 focus:ring-green-600 focus:ring-offset-green-50 focus:outline-0 focus:ring-0 focus:ring-offset-0 cursor-pointer")
    assert_selector "div[data-controller='components--ui--flash']"
    assert_text "hello world"
  end

  def test_render_error_component
    render_inline(Ui::Flash.new(message: "hello world", type: "error"))

    assert_component_rendered
    assert_selector("div", class: "rounded-md bg-red-50 p-4")
    assert_selector("p", class: "text-sm font-medium")
    assert_selector("button", class: "inline-flex rounded-md bg-red-50 p-1.5 text-red-500 hover:bg-red-100 focus:ring-red-600 focus:ring-offset-red-50 focus:outline-0 focus:ring-0 focus:ring-offset-0 cursor-pointer")
    assert_selector "div[data-controller='components--ui--flash']"
    assert_text "hello world"
  end

  def test_render_info_component
    render_inline(Ui::Flash.new(message: "hello world", type: "info"))

    assert_component_rendered
    assert_selector("div", class: "rounded-md bg-blue-50 p-4")
    assert_selector("p", class: "text-sm font-medium")
    assert_selector("button", class: "inline-flex rounded-md bg-blue-50 p-1.5 text-blue-500 hover:bg-blue-100 focus:ring-blue-600 focus:ring-offset-blue-50 focus:outline-0 focus:ring-0 focus:ring-offset-0 cursor-pointer")
    assert_selector "div[data-controller='components--ui--flash']"
    assert_text "hello world"
  end
end
