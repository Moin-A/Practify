# PaymentMethod - Base class for all payment gateway transactions
#
# Uses Single Table Inheritance (STI) to support multiple gateways:
#   - PaymentMethod::Razorpay
#   - PaymentMethod::Stripe (future)
#   - PaymentMethod::Paypal (future)
#
# Common attributes stored in base table:
#   - gateway_transaction_id: Gateway's transaction/payment ID
#   - gateway_order_id: Gateway's order ID
#   - gateway_data: JSONB for gateway-specific data
#   - amount: Amount in smallest currency unit (paise, cents)
#   - currency: Currency code (INR, USD)
#   - status: Payment status
#   - user_id: User who made the payment
#
class PaymentMethod < ApplicationRecord
  self.table_name = "payment_methods"
  
  has_many :payments, dependent: :destroy

  belongs_to :user, optional: true

  validates :gateway_transaction_id, presence: true, uniqueness: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true

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

  # Gateway name for display
  def gateway_name
    self.class.name.demodulize
  end

  # Override in subclasses for gateway-specific verification
  def verify_signature(signature)
    raise NotImplementedError, "Subclass must implement verify_signature"
  end

  # Override in subclasses to fetch payment details from gateway
  def fetch_from_gateway
    raise NotImplementedError, "Subclass must implement fetch_from_gateway"
  end
end
