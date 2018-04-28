require 'test_helper'

class SlotTest < ActiveSupport::TestCase
  def setup
    @fp = fps(:fp1)
    @user = users(:user1)
    @slot = @fp.slots.new(start_time: DateTime.now,
                            end_time: DateTime.now + Rational(1, 24))
  end

  test "should be valid" do
    assert @slot.valid?
  end

  test "fp id should be present" do
    @slot.fp_id = nil
    assert_not @slot.valid?
  end

  test "user id may not be present" do
    @slot.user_id = nil
    assert @slot.valid?
  end

  test "start time should be present" do
    @slot.start_time = nil
    assert_not @slot.valid?
  end

  test "end time should be present" do
    @slot.end_time = nil
    assert_not @slot.valid?
  end

  test "start time should be prior to end time" do
    @slot.start_time = DateTime.now
    @slot.end_time = DateTime.now
    assert_not @slot.valid?

    @slot.end_time = @slot.start_time - 1
    assert_not @slot.valid?

    @slot.end_time = @slot.start_time + 1
    assert @slot.valid?
  end

  test "order should be earliest first" do
    assert_equal slots(:earliest), Slot.first
  end
end
