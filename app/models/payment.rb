# Payment - Represents a payment for an appointment
#
# Links an appointment to a payment method (gateway transaction)
#
# Associations:
#   - belongs_to :appointment
#   - belongs_to :payment_method (PaymentMethod::Razorpay, etc.)
#
class Payment < ApplicationRecord
  belongs_to :appointment
  belongs_to :payment_method, optional: true

  validates :amount, presence: true, numericality: { greater_than: 0 }, if: :requires_payment_details?
  validates :currency, presence: true
  validates :status, presence: true
  validates :payment_method, presence: true, if: :requires_payment_details?

  private

  def requires_payment_details?
    payment_method_id.present? || status == "paid"
  end

  enum :status, {
    pending: "pending",
    paid: "paid",
    failed: "failed",
    refunded: "refunded"
  }, default: :pending

  scope :successful, -> { where(status: :paid) }
  scope :recent, -> { order(created_at: :desc) }

  # Amount in main currency unit (rupees, dollars)
  def amount_in_currency
    amount / 100.0
  end

  def display_amount
    symbol = currency == "INR" ? "₹" : "$"
    "#{symbol}#{amount_in_currency}"
  end
end
