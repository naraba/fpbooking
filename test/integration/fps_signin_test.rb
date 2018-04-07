require 'test_helper'

class FpsSigninTest < ActionDispatch::IntegrationTest
  def setup
    @fp = fps(:fp1)
  end

  test "signin with invalid information" do
    get new_fp_session_path
    assert_template 'fps/sessions/new'
    post fp_session_path, params: { fp: { email: "", password: "" } }
    assert_template 'fps/sessions/new'
    assert_equal 1, flash.count
    get root_path
    assert flash.empty?
  end

  test "signin with valid information followed by signout" do
    get new_fp_session_path
    assert_template 'fps/sessions/new'
    post fp_session_path, params: { fp: { email: @fp.email,
                                          password: "password" } }
    follow_redirect!
    assert_template 'static_pages/home'
    assert_equal 1, flash.count
    get root_path
    assert flash.empty?
    assert_select "a[href=?]", edit_fp_registration_path
    assert_select "a[href=?]", new_fp_session_path, count: 0
    assert_select "a[href=?]", destroy_fp_session_path

    # sign out
    delete destroy_fp_session_path
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", edit_fp_registration_path, count: 0
    assert_select "a[href=?]", new_fp_session_path, count: 0
    assert_select "a[href=?]", destroy_fp_session_path, count: 0
  end
end
