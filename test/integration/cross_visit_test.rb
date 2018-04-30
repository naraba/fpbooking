require 'test_helper'

class CrossVisitTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers
  def setup
    Warden.test_mode!
    @user = users(:user1)
    @fp = fps(:fp1)
  end

  test "signin user when a fp already signed in" do
    login_as(@fp, :scope => :fp)
    get new_user_session_path
    assert_template 'users/sessions/new'
    post user_session_path, params: { user: { email: @user.email,
                                              password: "password" } }
    follow_redirect!
    assert_template 'slots/index'
    assert_match "フィナンシャルプランナーとしてログイン中です", response.body
  end

  test "signup user when a fp already signed in" do
    login_as(@fp, :scope => :fp)
    get new_user_registration_path
    assert_template 'users/registrations/new'
    post user_registration_path, params: { user: { email: "user0",
                                           password: "password",
                                           password_confirmation: "password" } }
    follow_redirect!
    assert_template 'slots/index'
    assert_match "フィナンシャルプランナーとしてログイン中です", response.body
  end

  test "signin fp when an user already signed in" do
    login_as(@user, :scope => :user)
    get new_fp_session_path
    assert_template 'fps/sessions/new'
    post fp_session_path, params: { fp: { email: @fp.email,
                                          password: "password" } }
    follow_redirect!
    assert_template 'slots/index'
    assert_match "ユーザとしてログイン中です", response.body
  end

  test "signup fp when an user already signed in" do
    login_as(@user, :scope => :user)
    get new_fp_registration_path
    assert_template 'fps/registrations/new'
    post fp_registration_path, params: { fp: { email: "fp0",
                                         password: "password",
                                         password_confirmation: "password" } }
    follow_redirect!
    assert_template 'slots/index'
    assert_match "ユーザとしてログイン中です", response.body
  end
end
