class Appointment < ApplicationRecord
  belongs_to :user
  belongs_to :slot

  validates :user_id, presence: true
  validates :slot_id, presence: true, uniqueness: true
  validate :slot_must_be_available

  private

  def slot_must_be_available
    return unless slot

    errors.add(:slot_id, "must be available") unless slot.available?
  end
end
