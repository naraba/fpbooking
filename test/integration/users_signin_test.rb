require 'test_helper'

class UsersSigninTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:user1)
  end

  test "signin with invalid information" do
    get new_user_session_path
    assert_template 'users/sessions/new'
    post user_session_path, params: { user: { email: "", password: "" } }
    assert_template 'users/sessions/new'
    assert_equal 1, flash.count
    get root_path
    assert flash.empty?
  end

  test "signin with valid information followed by signout" do
    get new_user_session_path
    assert_template 'users/sessions/new'
    post user_session_path, params: { user: { email: @user.email,
                                                     password: "password" } }
    follow_redirect!
    assert_template 'static_pages/home'
    assert_equal 1, flash.count
    get root_path
    assert flash.empty?
    assert_select "a[href=?]", edit_user_registration_path
    assert_select "a[href=?]", new_user_session_path, count: 0
    assert_select "a[href=?]", destroy_user_session_path

    # sign out
    delete destroy_user_session_path
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", edit_user_registration_path, count: 0
    assert_select "a[href=?]", new_user_session_path
    assert_select "a[href=?]", destroy_user_session_path, count: 0
  end
end
