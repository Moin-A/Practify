class Appointment < ApplicationRecord
  belongs_to :user
  belongs_to :slot
  belongs_to :publisher, class_name: "User"
  belongs_to :subscriber, class_name: "User"
  has_one :call_room, dependent: :destroy
  delegate :start_at, :end_at, to: :slot

  enum :status, { pending: 0, noshow: 1, cancelled: 1, completed: 2, expired: 3, publisher_joined: 4, subscriber_joined: 5, in_progress: 6 }

  validates :user_id, presence: true
  validates :slot_id, presence: true, uniqueness: true
  validate :slot_must_be_available, if: -> { slot.present? }

  def update_joined_status
    user.has_joined!(self) do |role|
     self["#{role}_joined"] = true
    end
  end

  private


  def slot_must_be_available
    return unless slot

    errors.add(:slot_id, "must be available") unless slot.available?
  end
end
