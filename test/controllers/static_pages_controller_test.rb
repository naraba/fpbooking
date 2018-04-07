require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get root_path
    assert_response :success
    assert_select "title", "トップページ | Financial Planner Booking"
  end

  test "should get aboug" do
    get about_path
    assert_response :success
    assert_select "title", "このサイトについて | Financial Planner Booking"
  end
end
