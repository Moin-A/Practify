class PaymentCheckoutService
  attr_reader :appointment, :current_user, :errors, :options, :amount, :slot
  def initialize(appointment:, current_user:, slot:)
    @appointment = appointment
    @current_user = current_user
    @errors = []
    @slot = slot
  end

  def create(options = {})
    @options = options
    return errors unless valid?(options)
    key    = fetch_secret_keys(options[:gateway], :access_key_id)
    secret = fetch_secret_keys(options[:gateway], :secret_access_key)
    ::Razorpay.setup(key, secret)
    order = create_order(rupee_to_paise(amount))
    { order: order, key: key }
  end

   def valid?(options)
    validate_options
    validate_option_keys
    errors.empty?
   end

   def validate_options
    errors << "Gateway is required" if options[:gateway].blank?
   end

   def validate_option_keys
    options.assert_valid_keys(:gateway, :amount)
    rescue => error
      errors << "Invalid option key: #{error.message}"
   end

   def fetch_secret_keys(service_name, secret_key_name)
     key = Rails.application.credentials.dig(service_name, secret_key_name)
   end

   def amount
      slot.slot_credit.amount
   end

   def rupee_to_paise(amount)
    amount * 100
   end

   def create_order(amount)
    order = ::Razorpay::Order.create(
    amount:   amount,
    currency: "INR",
    receipt:  "rcpt_#{SecureRandom.hex(8)}"
  )
   end
end
