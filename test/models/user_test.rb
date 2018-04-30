require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @fp = Fp.new(email: "fp@example.com",
                 password: "foobar",
                 password_confirmation: "foobar")
    @user = User.new(email: "user@example.com",
                     password: "foobar",
                     password_confirmation: "foobar")
  end

  test "associated slots should be nullified" do
    @fp.save
    @user.save
    slot = @fp.slots.create!(start_time: DateTime.now,
                             end_time: DateTime.now + 30.minutes,
                             user_id: @user.id)
    assert_equal slot.user_id, @user.id
    assert_difference 'Slot.count', 0 do
      @user.destroy
    end
    assert_nil slot.reload.user_id
  end
end
