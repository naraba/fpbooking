class Slot < ApplicationRecord
  belongs_to :fp
  belongs_to :user, optional: true # user_id is nil if the slot is open
  default_scope -> { order(:start_time) }
  validates :fp_id, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :slot_duration_should_be_30min

  private
    def slot_duration_should_be_30min
      if start_time.present? && end_time.present? &&
        end_time - start_time != 30.minutes
        errors.add(:end_time, :slot_duration_invalid)
      end
    end

end
