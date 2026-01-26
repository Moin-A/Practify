# PaymentMethod::Razorpay - Razorpay-specific payment implementation
#
# Stores Razorpay-specific data in gateway_data JSON:
#   - signature: HMAC-SHA256 signature for verification
#
# Usage:
#   payment = PaymentMethod::Razorpay.create!(
#     gateway_transaction_id: "pay_xxx",
#     gateway_order_id: "order_xxx",
#     amount: 500,
#     currency: "INR",
#     status: :paid,
#     user: current_user
#   )
#   payment.signature = "abc123..."
#
class PaymentMethod::Razorpay < PaymentMethod
  # Convenience accessors for gateway_data
  def signature
    gateway_data["signature"]
  end

  def signature=(value)
    self.gateway_data = gateway_data.merge("signature" => value)
  end

  # Alias for backward compatibility
  def razorpay_payment_id
    gateway_transaction_id
  end

  def razorpay_order_id
    gateway_order_id
  end

  # Verify Razorpay signature
  def verify_signature(provided_signature)
    secret = ::Rails.application.credentials.dig(:razorpay, :secret_access_key)
    data = "#{gateway_order_id}|#{gateway_transaction_id}"

    expected = OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new("sha256"),
      secret,
      data
    )

    ActiveSupport::SecurityUtils.secure_compare(expected, provided_signature)
  end

  # Fetch payment details from Razorpay API
  def fetch_from_gateway
    setup_razorpay
    ::Razorpay::Payment.fetch(gateway_transaction_id)
  rescue ::Razorpay::Error => e
    Rails.logger.error "Razorpay fetch error: #{e.message}"
    nil
  end

  # Create order via Razorpay API
  def self.create_order(amount:, currency: "INR", receipt: nil, notes: {})
    setup_razorpay
    ::Razorpay::Order.create(
      amount: amount,
      currency: currency,
      receipt: receipt || "rcpt_#{SecureRandom.hex(8)}",
      notes: notes.compact
    )
  end

  # Get API key for Checkout.js
  def self.api_key
    ::Rails.application.credentials.dig(:razorpay, :access_key_id)
  end

  private

  def self.setup_razorpay
    ::Razorpay.setup(
      ::Rails.application.credentials.dig(:razorpay, :access_key_id),
      ::Rails.application.credentials.dig(:razorpay, :secret_access_key)
    )
  end

  def setup_razorpay
    self.class.setup_razorpay
  end
end
