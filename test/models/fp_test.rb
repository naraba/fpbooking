require 'test_helper'

class FpTest < ActiveSupport::TestCase
  def setup
    @fp = Fp.new(email: "fp@example.com",
                 password: "foobar",
                 password_confirmation: "foobar")
  end

  test "associated slots should be destroyed" do
    @fp.save
    @fp.slots.create!(start_time: DateTime.now,
                      end_time: DateTime.now + Rational(1, 24))
    assert_difference 'Slot.count', -1 do
      @fp.destroy
    end
  end
end
