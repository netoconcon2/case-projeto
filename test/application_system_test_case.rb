require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # driven_by :selenium, using: :chrome, screen_size: [1200, 800]
  driven_by :headless_chrome

  # def take_failed_screenshot
  #   true
  # end
end
