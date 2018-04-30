require 'test_helper'

class FpsEditAndCancelTest < ActionDispatch::IntegrationTest
  def setup
    @fp = fps(:fp1)
  end

  test "get with no-signed fp" do
    get edit_fp_registration_path
    follow_redirect!
    assert_template 'fps/sessions/new'
  end

  test "signin and edit with invalid information" do
    # signin
    get new_fp_session_path
    assert_template 'fps/sessions/new'
    post fp_session_path, params: { fp: { email: @fp.email,
                                          password: "password" } }
    follow_redirect!
    assert_template 'slots/index'

    # edit
    get edit_fp_registration_path
    assert_template 'fps/registrations/edit'
    patch fp_registration_path, params: { fp: { email: @fp.email,
                                                password: "",
                                                password_confirmation: "",
                                                current_password: "" } }
    assert_template 'fps/registrations/edit'
    assert_select 'div#error_explanation'
  end

  test "signin and edit with valid information folllowed by cancel" do
    # signin
    get new_fp_session_path
    assert_template 'fps/sessions/new'
    post fp_session_path, params: { fp: { email: @fp.email,
                                          password: "password" } }
    follow_redirect!
    assert_template 'slots/index'

    # edit
    get edit_fp_registration_path
    assert_template 'fps/registrations/edit'
    patch fp_registration_path, params: { fp: { email: @fp.email,
                                                password: "password2",
                                                password_confirmation: "password2",
                                                current_password: "password" } }
    follow_redirect!
    assert_template 'slots/index'
    assert_equal 1, flash.count

    # cancel
    assert_difference 'Fp.count', -1 do
      delete fp_registration_path
    end
    assert_equal 1, flash.count
    follow_redirect!
    assert_template 'static_pages/home'
    assert_select "a[href=?]", new_user_session_path
    assert_select "a[href=?]", destroy_user_session_path, count: 0
  end
end
