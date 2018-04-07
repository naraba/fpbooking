require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "full title helper" do
    assert_equal full_title, "Financial Planner Booking"
    assert_equal full_title("Test"), "Test | Financial Planner Booking"
  end
end
