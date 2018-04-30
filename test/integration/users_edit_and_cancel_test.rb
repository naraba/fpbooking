require 'test_helper'

class UsersEditAndCancelTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:user1)
  end

  test "get with no-signed user" do
    get edit_user_registration_path
    follow_redirect!
    assert_template 'users/sessions/new'
  end

  test "signin and edit with invalid information" do
    # signin
    get new_user_session_path
    assert_template 'users/sessions/new'
    post user_session_path, params: { user: { email: @user.email,
                                              password: "password" } }
    follow_redirect!
    assert_template 'slots/index'

    # edit
    get edit_user_registration_path
    assert_template 'users/registrations/edit'
    patch user_registration_path, params: { user: { email: @user.email,
                                                    password: "",
                                                    password_confirmation: "",
                                                    current_password: "" } }
    assert_template 'users/registrations/edit'
    assert_select 'div#error_explanation'
  end

  test "signin and edit with valid information followed by cancel" do
    # signin
    get new_user_session_path
    assert_template 'users/sessions/new'
    post user_session_path, params: { user: { email: @user.email,
                                              password: "password" } }
    follow_redirect!
    assert_template 'slots/index'

    # edit
    get edit_user_registration_path
    assert_template 'users/registrations/edit'
    patch user_registration_path, params: { user: { email: @user.email,
                                                    password: "password2",
                                                    password_confirmation: "password2",
                                                    current_password: "password" } }
    follow_redirect!
    assert_template 'slots/index'
    assert_equal 1, flash.count

    # cancel
    assert_difference 'User.count', -1 do
      delete user_registration_path
    end
    assert_equal 1, flash.count
    follow_redirect!
    assert_template 'static_pages/home'
    assert_select "a[href=?]", new_user_session_path
    assert_select "a[href=?]", destroy_user_session_path, count: 0
  end
end
