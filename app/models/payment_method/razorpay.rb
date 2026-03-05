# ActiveMerchant::Billing::Razorpay - ActiveMerchant-compatible gateway using the Razorpay Ruby SDK
#
# Conforms to the ActiveMerchant gateway interface:
#   purchase   - Create + capture a payment in one step
#   authorize  - Create a payment and hold (no capture)
#   capture    - Capture a previously authorised payment
#   void       - Refund/cancel an authorized payment
#   refund     - Refund a captured payment
#
# Configuration (pass via options hash or Rails credentials):
#   :api_key_id        - Razorpay key ID  (rzp_live_xxx / rzp_test_xxx)
#   :secret_access_key - Razorpay secret
#   :test              - Boolean, true for test/sandbox mode
#
# Example:
#   gateway = ActiveMerchant::Billing::Razorpay.new(
#     api_key_id:        Rails.application.credentials.dig(:razorpay, :access_key_id),
#     secret_access_key: Rails.application.credentials.dig(:razorpay, :secret_access_key),
#     test: Rails.env.development?
#   )
#   response = gateway.purchase(10_000, source, { currency: 'INR', order_id: 'ORDER-1' })
#   response.success?      # => true / false
#   response.authorization # => Razorpay payment_id
#
module ActiveMerchant
  module Billing
    class Razorpay < Gateway
      self.supported_countries = ['IN']
      self.default_currency    = 'INR'
      self.homepage_url        = 'https://razorpay.com'
      self.display_name        = 'Razorpay'

      # ---------------------------------------------------------------
      # Initialise the gateway and configure the Razorpay SDK.
      # Options:
      #   :api_key_id        - Razorpay key ID
      #   :secret_access_key - Razorpay secret
      #   :test              - Boolean sandbox flag
      # ---------------------------------------------------------------
      def initialize(options = {})
        @api_key_id        = options[:api_key_id]        ||
                             ::Rails.application.credentials.dig(:razorpay, :access_key_id)
        @secret_access_key = options[:secret_access_key] ||
                             ::Rails.application.credentials.dig(:razorpay, :secret_access_key)
        @test              = options.fetch(:test, false)

        ::Razorpay.setup(@api_key_id, @secret_access_key)
        super
      end

      # ---------------------------------------------------------------
      # Purchase – create an order then immediately capture the payment.
      # Razorpay hosted checkout: pass razorpay_payment_id as `source`.
      #
      # @param money   [Integer]        Amount in smallest currency unit (paise)
      # @param source  [String|Object]  razorpay_payment_id string, or an
      #                                 object responding to #gateway_payment_profile_id
      # @param options [Hash]
      #   :currency   - 'INR' (default)
      #   :order_id   - Razorpay order ID (rzp order created beforehand)
      #   :receipt    - Optional receipt string
      #   :notes      - Hash of key/value notes
      # ---------------------------------------------------------------
      def purchase(money, source, options = {})
        payment_id = payment_id_from(source)
        return error_response('No payment ID provided') if payment_id.blank?

        begin
          payment = ::Razorpay::Payment.fetch(payment_id)

          # Auto-capture if not already captured
          if payment.status == 'authorized'
            payment = payment.capture(amount: money)
          end

          success = payment.status == 'captured'
          ActiveMerchant::Billing::Response.new(
            success,
            payment.status,
            payment.respond_to?(:to_hash) ? payment.to_hash : {},
            authorization: payment.id,
            test: @test
          )
        rescue ::Razorpay::Error => e
          error_response(e.message)
        end
      end

      # ---------------------------------------------------------------
      # Authorize – create a Razorpay order with payment_capture: 0.
      # Returns the Razorpay *order* ID as authorization for later capture.
      # ---------------------------------------------------------------
      def authorize(money, _source, options = {})
        begin
          order = ::Razorpay::Order.create(
            amount:          money,
            currency:        options[:currency] || self.default_currency,
            receipt:         options[:receipt]  || "rcpt_#{SecureRandom.hex(8)}",
            payment_capture: 0,
            notes:           (options[:notes] || {}).compact
          )

          ActiveMerchant::Billing::Response.new(
            true,
            'Order created – awaiting capture',
            order.respond_to?(:to_hash) ? order.to_hash : {},
            authorization: order.id,
            test: @test
          )
        rescue ::Razorpay::Error => e
          error_response(e.message)
        end
      end

      # ---------------------------------------------------------------
      # Capture – capture a previously authorized payment.
      # @param authorization [String] razorpay_payment_id returned by purchase/authorize
      # ---------------------------------------------------------------
      def capture(money, authorization, options = {})
        begin
          payment  = ::Razorpay::Payment.fetch(authorization)
          captured = payment.capture(amount: money)

          ActiveMerchant::Billing::Response.new(
            captured.status == 'captured',
            captured.status,
            captured.respond_to?(:to_hash) ? captured.to_hash : {},
            authorization: captured.id,
            test: @test
          )
        rescue ::Razorpay::Error => e
          error_response(e.message)
        end
      end

      # ---------------------------------------------------------------
      # Void – refund an authorized (not yet captured) payment.
      # Razorpay does not support true void; a full refund is issued.
      # ---------------------------------------------------------------
      def void(authorization, options = {})
        begin
          payment = ::Razorpay::Payment.fetch(authorization)
          refund  = payment.refund(amount: payment.amount)

          ActiveMerchant::Billing::Response.new(
            %w[processed pending].include?(refund.status),
            refund.status,
            refund.respond_to?(:to_hash) ? refund.to_hash : {},
            authorization: refund.id,
            test: @test
          )
        rescue ::Razorpay::Error => e
          error_response(e.message)
        end
      end

      # ---------------------------------------------------------------
      # Refund – partial or full refund of a captured payment.
      # @param money         [Integer] Amount in paise (pass nil for full refund)
      # @param authorization [String]  razorpay_payment_id
      # ---------------------------------------------------------------
      def refund(money, authorization, options = {})
        begin
          payment = ::Razorpay::Payment.fetch(authorization)
          params  = { notes: (options[:notes] || {}).compact }
          params[:amount] = money if money.present?

          refund = payment.refund(params)

          ActiveMerchant::Billing::Response.new(
            %w[processed pending].include?(refund.status),
            refund.status,
            refund.respond_to?(:to_hash) ? refund.to_hash : {},
            authorization: refund.id,
            test: @test
          )
        rescue ::Razorpay::Error => e
          error_response(e.message)
        end
      end

      # ---------------------------------------------------------------
      # Verify HMAC-SHA256 signature returned by Razorpay Checkout.js
      # ---------------------------------------------------------------
      def verify_signature(order_id, payment_id, provided_signature)
        data     = "#{order_id}|#{payment_id}"
        expected = OpenSSL::HMAC.hexdigest(
          OpenSSL::Digest.new('sha256'),
          @secret_access_key,
          data
        )
        ActiveSupport::SecurityUtils.secure_compare(expected, provided_signature)
      end

      private

      def payment_id_from(source)
        return source if source.is_a?(String)
        return source.gateway_transaction_id if source.respond_to?(:gateway_transaction_id)
        return source.gateway_payment_profile_id if source.respond_to?(:gateway_payment_profile_id)

        nil
      end

      def error_response(message)
        ActiveMerchant::Billing::Response.new(false, message, {}, test: @test)
      end
    end
  end
end

# ---------------------------------------------------------------------------
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
