# frozen_string_literal: true

class Ui::Flash < ViewComponent::Base
  def initialize(message:, type:)
    @message = message
    @type = type
  end

  # Get status classes for various type display
  def type_classes
    {
      success: {
        bg: "bg-green-50",
        text: "text-green-800",
        button: "text-green-500 hover:bg-green-100 focus:ring-green-600 focus:ring-offset-green-50"
      },
      error: {
        bg: "bg-red-50",
        text: "text-red-800",
        button: "text-red-500 hover:bg-red-100 focus:ring-red-600 focus:ring-offset-red-50"
      },
      info: {
        bg: "bg-blue-50",
        text: "text-blue-800",
        button: "text-blue-500 hover:bg-blue-100 focus:ring-blue-600 focus:ring-offset-blue-50"
      }
    }[@type.to_sym]
  end
end
