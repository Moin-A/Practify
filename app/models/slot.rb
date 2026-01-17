class Slot < ApplicationRecord
  belongs_to :calendar
  has_one :appointment, dependent: :destroy

  enum status: {
    draft: 0,
    available: 1
  }

  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :calendar_id, presence: true
  validates :status, presence: true

  validate :end_at_after_start_at

  private

  def end_at_after_start_at
    return unless start_at && end_at

    errors.add(:end_at, "must be after start_at") if end_at <= start_at
  end
end
