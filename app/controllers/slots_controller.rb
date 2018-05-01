class SlotsController < ApplicationController
  before_action -> {
    # if neither fp nor user signed in, redirect to user login
    fp_signed_in? || authenticate_user!
  }

  def index
    gon.fp_signed_in = fp_signed_in?
    gon.user_signed_in = user_signed_in?

    # ugly patch(adding 9hours) for timezone gap
    past = Time.now + 9.hour - 1.day
    if fp_signed_in?
      booked = current_fp.slots.where.not(user_id: nil).where("start_time > ?", past)
        .select('start_time as start, end_time as end, "予約された枠" as title, "booked-slot" as className')
      opens = current_fp.slots.where(user_id: nil).where("start_time > ?", past)
        .select('start_time as start, end_time as end, "open-slot" as className')

      @events = booked.to_a.concat(opens.to_a)
    elsif user_signed_in?
      # booked slots
      booked = current_user.slots.where("start_time > ?", past)
        .select('start_time as start, end_time as end, "あなたの予約" as title, "booked-slot" as className')
      timespots = booked.pluck(:start_time)

      # open slots group by start and end time except for the same timespots of booked slots
      opens = Slot.where(user_id: nil).where("start_time > ?", past)
        .where.not(start_time: timespots).group(:start_time, :end_time)
        .select('start_time as start, end_time as end, count(*) as title, "open-slot" as className')

      @events = booked.to_a.concat(opens.to_a)
    end

    @recent_slots = get_recent_slots

    respond_to do |format|
      format.html
      format.xml { render :xml => @events }
      format.json { render :json => @events }
    end
  end

  def create
    if fp_signed_in?
      begin
        ActiveRecord::Base.transaction do
          if after_24hours?(params[:start])
            raise ArgumentError, t('.open_slot_after_today')
          elsif !business_hours?
            raise ArgumentError, t('.open_slot_business_hour')
          elsif !timeunit_30min?
            raise ArgumentError, t('.open_slot_timeunits')
          end

          opened = current_fp.slots.where(start_time: params[:start])
          raise ArgumentError, t('.double_opened') if opened.length > 0

          # register slots every 30 minutes
          cslot = DateTime.parse(params[:start])
          edat = DateTime.parse(params[:end])
          while cslot < edat
            cslotEnd = cslot + 30.minutes
            slot = current_fp.slots.new
            slot.attributes = {
              start_time: cslot.iso8601,
              end_time: cslotEnd.iso8601
            }
            slot.save!
            cslot = cslotEnd
          end
        end
        flash.now[:success] = t('.opened_slot')
        render partial: "layouts/alert", status: 200
      rescue => e
        error_handler e
      end
    end
  end

  def update
    if user_signed_in?
      begin
        ActiveRecord::Base.transaction do
          if after_24hours?(params[:start])
            raise ArgumentError, t('.book_slot_after_today')
          end

          booked = current_user.slots.where(start_time: params[:start])
          raise ArgumentError, t('.double_booking') if booked.length > 0

          # pick a random open slot
          aSlotId = Slot
            .where(start_time: params[:start],
              end_time: params[:end], user_id: nil)
            .pluck(:id).sample
          slot = Slot.find(aSlotId)
          # book
          slot.attributes = {
            user_id: current_user.id
          }
          slot.save!
        end
        flash.now[:success] = t('.booked_slot')
        render partial: "layouts/alert", status: 200
      rescue => e
        error_handler e
      end
    end
  end

  def render_user_recent
    if user_signed_in?
      @recent_slots = get_recent_slots
      render partial: "slots/recent"
    else
      # no need for fp because fp himself does not update his slots
      redirect_to action: :index
    end
  end

  def destory
  end

  private
    def error_handler(e)
      logger.error e.message
      logger.error e.backtrace.join("\n")
      flash.now[:danger] = e.message
      render partial: "layouts/alert", status: 400
    end

    def after_24hours?(date)
      return DateTime.parse(date) < DateTime.now + 24.hours
    end

    def business_hours?
      sdat = DateTime.parse(params[:start])
      edat = DateTime.parse(params[:end])
      return false if sdat.nil? or edat.nil?
      if sdat.on_weekday?
        bstart = Time.utc(sdat.year, sdat.month, sdat.day, 10, 0, 0)
        bend = Time.utc(edat.year, edat.month, edat.day, 18, 0, 0)
        return (bstart <= sdat and edat <= bend)
      elsif sdat.saturday?
        bstart = Time.utc(sdat.year, sdat.month, sdat.day, 11, 0, 0)
        bend = Time.utc(edat.year, edat.month, edat.day, 15, 0, 0)
        return (bstart <= sdat and edat <= bend)
      end
      return false
    end

    def timeunit_30min?
      sdat = DateTime.parse(params[:start])
      edat = DateTime.parse(params[:end])
      return false if sdat.nil? or edat.nil?
      valid_mins = [0, 30]
      return (sdat.min.in?(valid_mins) and edat.min.in?(valid_mins))
    end

    def get_recent_slots
      # ugly patch(adding 9hours) for timezone gap
      if fp_signed_in?
        current_fp.users.includes(:slots)
          .limit(10).select(:start_time, :email)
          .where("start_time > ?", Time.now + 9.hour).to_a
      elsif user_signed_in?
        current_user.fps.includes(:slots)
          .limit(10).select(:start_time, :email)
          .where("start_time > ?", Time.now + 9.hour).to_a
      end
    end
end
