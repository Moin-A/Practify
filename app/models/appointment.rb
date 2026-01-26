class Appointment < ApplicationRecord
  belongs_to :user
  belongs_to :slot
  has_many :payments, dependent: :destroy, autosave: false

  validates :user_id, presence: true
  validates :slot_id, presence: true, uniqueness: true
  validate :slot_must_be_available, if: -> { slot.present? }

  after_initialize :initialize_payment, if: :new_record?

  private

  def initialize_payment
    if payments.empty?
      payment = payments.build
      # Set standard defaults - payment will be saved later when payment_method is added
      payment.amount = 10000 # ₹100.00 in paise
      payment.currency = "INR"
      payment.status = :pending
      # payment_method will be set later during checkout
    end
  end


  private

  def slot_must_be_available
    return unless slot

    errors.add(:slot_id, "must be available") unless slot.available?
  end
end
