require "test_helper"

class MobileSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :iphone_8_headless

  # def take_failed_screenshot
  #   false
  # end
end
