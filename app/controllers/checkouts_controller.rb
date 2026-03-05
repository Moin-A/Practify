class CheckoutsController < ApplicationController
  def new
    gateway = ActiveMerchant::Billing::Razorpay.new(test: Rails.env.development?)

    @amount = (params[:amount] || 10_000).to_i  # paise — default ₹100
    @order  = ::Razorpay::Order.create(
      amount:   @amount,
      currency: "INR",
      receipt:  "rcpt_#{SecureRandom.hex(8)}"
    )
    @razorpay_key = Rails.application.credentials.dig(:razorpay, :access_key_id)
  rescue StandardError => e
    Rails.logger.error "Razorpay order creation failed: #{e.message}"
    @order = nil
    flash.now[:alert] = "Unable to create payment order: #{e.message}"
  end

  def verify
    order_id   = params[:razorpay_order_id]
    payment_id = params[:razorpay_payment_id]
    signature  = params[:razorpay_signature]

    gateway = ActiveMerchant::Billing::Razorpay.new(test: Rails.env.development?)

    if gateway.verify_signature(order_id, payment_id, signature)
      # Signature is valid — payment is genuine
      redirect_to root_path, notice: "Payment successful! Payment ID: #{payment_id}"
    else
      redirect_to new_checkout_path, alert: "Payment verification failed — signature mismatch."
    end
  rescue StandardError => e
    Rails.logger.error "Checkout verify error: #{e.message}"
    redirect_to new_checkout_path, alert: "Payment error: #{e.message}"
  end
end
