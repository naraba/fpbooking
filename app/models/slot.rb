class Slot < ApplicationRecord
  belongs_to :fp
  belongs_to :user, optional: true # user_id is nil if the slot is open
  default_scope -> { order(:start_time) }
  validates :fp_id, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :start_should_be_prior_to_end

  private
    def start_should_be_prior_to_end
        if start_time.present? && end_time.present? && start_time >= end_time
          errors.add(:end_time, :prior_to_start)
        end
    end
end
