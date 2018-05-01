require 'test_helper'

class SlotsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  def setup
    @fp = fps(:fp1)
    @user = users(:user1)
    @today_slot = slots(:today)
    @future_slot = slots(:double1)

    stime = (Time.now.utc + 3.days).change(hour: 13, min: 0, sec: 0)
    while stime.wday != 0 do
      stime = stime.tomorrow
    end
    etime = stime + 30.minutes
    @sunday_params = { start: stime.iso8601, end: etime.iso8601 }

    stime = stime.tomorrow
    etime = etime.tomorrow
    @monday_params = { start: stime.iso8601, end: etime.iso8601 }
    @mon1300 = stime
  end

  test "should redirect index when not signed in" do
    get slots_path
    assert_redirected_to new_user_session_path
  end

  test "should redirect create when not signed in" do
    post slots_create_path, params: @monday_params
    assert_redirected_to new_user_session_path
  end

  test "should redirect update when not signed in" do
    post slots_update_path, params: @monday_params
    assert_redirected_to new_user_session_path
  end

  test "get index when signed in as fp including his recent slots" do
    sign_in(@fp)
    get slots_path
    assert_template 'slots/index'
    assert_select ".recent-slots > table > tr", count: 2 # th and 1 td
  end

  test "get index as json when signed in as fp" do
    sign_in(@fp)
    get '/slots.json'
    assert_equal 3, JSON.parse(response.body).length
  end

  test "get index when signed in as user including his recent slots" do
    sign_in(@user)
    get slots_path
    assert_template 'slots/index'
    assert_select ".recent-slots > table > tr", count: 2 # th and 1 td
  end

  test "get index as json when signed in as user" do
    sign_in(@user)
    get '/slots.json'
    assert_equal 3, JSON.parse(response.body).length
  end

  test "should not create slot when signed as user" do
    sign_in(@user)
    assert_no_difference 'Slot.count' do
      post slots_create_path, params: @monday_params
    end
  end

  test "create slot when signed as fp and valid params" do
    sign_in(@fp)

    assert_difference 'Slot.count', 1 do
      post slots_create_path, params: @monday_params
    end
    assert_not_nil flash.now[:success]
  end

  test "should not create slots when today" do
    sign_in(@fp)

    params = {
      start: @today_slot.start_time,
      end: @today_slot.end_time
    }
    assert_no_difference 'Slot.count' do
      post slots_create_path, params: params
    end
    assert_not_nil flash.now[:danger]
  end

  test "should not create slots outside bussiness hours" do
    sign_in(@fp)

    ## weekday
    # 09:30-
    st = @mon1300.change(hour: 9, min: 30)
    params = {
      start: st.iso8601,
      end: st.since(30.minute).iso8601
    }
    assert_no_difference 'Slot.count' do
      post slots_create_path, params: params
    end
    assert_not_nil flash.now[:danger]

    # 18:00-
    st = @mon1300.change(hour: 18, min: 0)
    params = {
      start: st.iso8601,
      end: st.since(30.minute).iso8601
    }
    assert_no_difference 'Slot.count' do
      post slots_create_path, params: params
    end
    assert_not_nil flash.now[:danger]

    ## saturday
    # 10:30-
    st = @mon1300.ago(2.day).change(hour: 10, min: 30)
    params = {
      start: st.iso8601,
      end: st.since(30.minute).iso8601
    }
    assert_no_difference 'Slot.count' do
      post slots_create_path, params: params
    end
    assert_not_nil flash.now[:danger]

    # 15:00-
    st = @mon1300.ago(2.day).change(hour: 15, min: 0)
    params = {
      start: st.iso8601,
      end: st.since(30.minute).iso8601
    }
    assert_no_difference 'Slot.count' do
      post slots_create_path, params: params
    end
    assert_not_nil flash.now[:danger]

    ## sunday
    assert_no_difference 'Slot.count' do
      post slots_create_path, params: @sunday_params
    end
    assert_not_nil flash.now[:danger]
  end

  test "create slots within bussiness hours" do
    sign_in(@fp)

    ## weekday
    # 10:00-
    st = @mon1300.change(hour: 10, min: 0)
    params = {
      start: st.iso8601,
      end: st.since(30.minute).iso8601
    }
    assert_difference 'Slot.count', 1 do
      post slots_create_path, params: params
    end
    assert_not_nil flash.now[:success]

    # 17:30-
    st = @mon1300.change(hour: 17, min: 30)
    params = {
      start: st.iso8601,
      end: st.since(30.minute).iso8601
    }
    assert_difference 'Slot.count', 1 do
      post slots_create_path, params: params
    end
    assert_not_nil flash.now[:success]

    ## saturday
    # 11:00-
    st = @mon1300.ago(2.day).change(hour: 11, min: 0)
    params = {
      start: st.iso8601,
      end: st.since(30.minute).iso8601
    }
    assert_difference 'Slot.count', 1 do
      post slots_create_path, params: params
    end
    assert_not_nil flash.now[:success]

    # 14:30-
    st = @mon1300.ago(2.day).change(hour: 14, min: 30)
    params = {
      start: st.iso8601,
      end: st.since(30.minute).iso8601
    }
    assert_difference 'Slot.count', 1 do
      post slots_create_path, params: params
    end
    assert_not_nil flash.now[:success]
  end

  test "should not create slots when not based on 30 minutes unit" do
    sign_in(@fp)

    st = @mon1300.change(min: 1)
    params = {
      start: st.iso8601,
      end: st.since(30.minute).iso8601
    }
    assert_no_difference 'Slot.count' do
      post slots_create_path, params: params
    end
    assert_not_nil flash.now[:danger]
  end

  test "should not create slots when already opened" do
    sign_in(@fp)

    assert_difference 'Slot.count', 1 do
      post slots_create_path, params: @monday_params
      post slots_create_path, params: @monday_params
    end
    assert_not_nil flash.now[:danger]
  end

  test "create multiple slots when based on 30 minutes unit" do
    sign_in(@fp)

    params = {
      start: @mon1300.iso8601,
      end: @mon1300.since(4.hour).iso8601
    }
    assert_difference 'Slot.count', 8 do
      post slots_create_path, params: params
    end
    assert_not_nil flash.now[:success]
  end

  test "should not book slot when signed as fp" do
    sign_in(@fp)

    params = {
      start: @future_slot.start_time,
      end: @future_slot.end_time
    }
    post slots_update_path, params: params
    assert_nil @future_slot.reload.user_id
  end

  test "book slot when signed as user" do
    sign_in(@user)

    params = {
      start: @future_slot.start_time,
      end: @future_slot.end_time
    }
    post slots_update_path, params: params

    # CAUTION: there is no guarantee that @future_slot was booked
    # because a booking slot is randomly chosen by update action,
    # so we should assert the below line instead of @future_slot.reload.user_id
    booked = Slot.where(start_time: params[:start], user_id: @user.id)
    assert_equal 1, booked.length
    assert_not_nil flash.now[:success]
  end

  test "should not book slots when today" do
    sign_in(@user)

    params = {
      start: @today_slot.start_time,
      end: @today_slot.end_time
    }
    post slots_update_path, params: params
    assert_nil @today_slot.reload.user_id
    assert_not_nil flash.now[:danger]
  end

  test "should not book slots when already booked for the same timespot" do
    sign_in(@user)

    slot = slots(:triple2)
    params = {
      start: slot.start_time,
      end: slot.end_time
    }
    post slots_update_path, params: params
    assert_nil @today_slot.reload.user_id
    assert_not_nil flash.now[:danger]
  end

  test "should redirect reder_user_recent when not signed in" do
    get slots_render_user_recent_path
    assert_redirected_to new_user_session_path
  end

  test "should redirect reder_user_recent when signed in as fp" do
    sign_in(@fp)

    get slots_render_user_recent_path
    assert_redirected_to slots_path
  end

  test "should render recent when signed in as user" do
    sign_in(@user)

    get slots_render_user_recent_path
    assert_template 'slots/_recent'
    assert_select ".recent-slots > table > tr", count: 2 # th and 1 td
  end

end
