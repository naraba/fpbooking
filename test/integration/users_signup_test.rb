require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup" do
    get new_user_registration_path
    assert_no_difference 'User.count' do
      post user_registration_path,
           params: { user: { email: "test@invalid",
                             password: "foo",
                             password_confirmation: "bar"} }
    end
    assert_template 'users/registrations/new'
    assert_select 'div#error_explanation'
  end

  test "valid signup" do
    get new_user_registration_path
    assert_difference 'User.count', 1 do
      post user_registration_path,
           params: { user: { email: "test@example.com",
                             password: "foobar123",
                             password_confirmation: "foobar123"} }
    end
    assert_equal 1, flash.count
    follow_redirect!
    assert_template 'static_pages/home'
    assert_select "a[href=?]", new_user_session_path, count: 0
    assert_select "a[href=?]", destroy_user_session_path
  end
end
