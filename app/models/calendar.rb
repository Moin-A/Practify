class Calendar < ApplicationRecord
  belongs_to :user
  has_many :slots, dependent: :destroy

  validates :timezone, presence: true
  validates :user_id, presence: true

  def slots_for_date(date = Date.current)
    start_of_day = date.beginning_of_day
    end_of_day = date.end_of_day
    slots.where(start_at: start_of_day..end_of_day)
  end

  def appointments_for_date(date = Date.current)
    start_of_day = date.beginning_of_day
    end_of_day = date.end_of_day
    user.appointments.joins(:slot).where(slots: { start_at: start_of_day..end_of_day })
  end
end
