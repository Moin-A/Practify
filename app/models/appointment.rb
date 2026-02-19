class Appointment < ApplicationRecord
  belongs_to :user
  belongs_to :slot
  belongs_to :publisher, class_name: "User"
  belongs_to :subscriber, class_name: "User"
  has_one :call_room, dependent: :destroy
  delegate :start_at, :end_at, to: :slot

  scope :pending_or_in_progress_or_completed_or_booked, -> { where(status: [ :pending, :in_progress, :completed, :booked ]) }
  scope :active, -> { where(status: [ "booked", "in_progress", "pending" ]) }
  enum :status, { pending: 0, noshow: 1, cancelled: 2, completed: 3, expired: 4, in_progress: 5, booked: 6 }

  validates :user_id, presence: true
  validates :slot_id, presence: true, uniqueness: true
  validate :slot_must_be_available, if: -> { slot.present? }

  def update_joined_status
    user.has_joined!(self) do |role|
     self["#{role}_joined"] = true
    end
  end

  def publisher_or_subscriber_joined?
    publisher_joined? || subscriber_joined?
  end

  private

  def slot_must_be_available
    return unless slot

    errors.add(:slot_id, "must be available") unless slot.available?
  end
end
