require 'test_helper'

class FpsSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup" do
    get new_fp_registration_path
    assert_no_difference 'Fp.count' do
      post fp_registration_path,
           params: { fp: { email: "test@invalid",
                             password: "foo",
                             password_confirmation: "bar"} }
    end
    assert_template 'fps/registrations/new'
    assert_select 'div#error_explanation'
  end

  test "valid signup" do
    get new_fp_registration_path
    assert_difference 'Fp.count', 1 do
      post fp_registration_path,
           params: { fp: { email: "test@example.com",
                             password: "foobar123",
                             password_confirmation: "foobar123"} }
    end
    assert_equal 1, flash.count
    follow_redirect!
    assert_template 'static_pages/home'
    assert_select "a[href=?]", new_fp_session_path, count: 0
    assert_select "a[href=?]", destroy_fp_session_path
  end
end
