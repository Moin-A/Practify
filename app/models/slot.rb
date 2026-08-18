class Slot < ApplicationRecord
  belongs_to :calendar
  has_one :appointment, dependent: :destroy
  has_one :slot_credit, dependent: :destroy
  has_one :user, through: :calendar


  enum :status, { draft: 0, available: 1, booked: 2 }
  scope :available_on, ->(data) { where(start_at: data.beginning_of_day..data.end_of_day) }
  scope :available, -> { where(status: :available) }

  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :calendar_id, presence: true
  validates :status, presence: true
  validate :start_at_must_be_in_future

  validate :end_at_after_start_at

  def available?
    status == "available" && appointment.nil?
  end

  private

  def end_at_after_start_at
    return unless start_at && end_at

    errors.add(:end_at, "must be after start_at") if end_at <= start_at
  end

  def start_at_must_be_in_future
    return unless start_at

    errors.add(:start_at, "must be present or future") if start_at < Time.current
  end
end
