# Checkout Controller - Razorpay Checkout.js Integration
#
# Uses Payment::Razorpay for Razorpay payments.
# Can be extended for other gateways (Stripe, PayPal, etc.)
#
class CheckoutsController < ApplicationController
  def new
    @appointment_id = params[:appointment_id]
    @appointment = Appointment.find_by(id: @appointment_id, user: Current.user) if @appointment_id
    
    # Create or get payment for appointment
    if @appointment
      @payment = @appointment.payments.find_or_initialize_by(payment_method_id: nil)
      if @payment.new_record?
        @payment.amount = 10000 # ₹100.00 in paise
        @payment.currency = "INR"
        @payment.status = :pending
        @payment.save! # Save payment without payment_method
      end
      @amount = @payment.amount
    else
      @amount = (params[:amount] || 10000).to_i # Default ₹100.00 (in paise)
    end
    
    begin
      @order = PaymentMethod::Razorpay.create_order(
        amount: @amount,
        notes: { 
          user_id: Current.user&.id, 
          email: Current.user&.email_address,
          appointment_id: @appointment_id
        }.compact
      )
      @razorpay_key = PaymentMethod::Razorpay.api_key
      Rails.logger.info "Razorpay order created: #{@order.id}, amount: #{@amount}"
    rescue StandardError => e
      Rails.logger.error "Razorpay order creation failed: #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")
      @order = nil
      flash.now[:alert] = "Unable to create payment order: #{e.message}"
    end
  end

  def verify
    payment_id = params[:razorpay_payment_id]
    order_id = params[:razorpay_order_id]
    signature = params[:razorpay_signature]

    # Build payment method (gateway transaction)
    payment_method = PaymentMethod::Razorpay.new(
      gateway_transaction_id: payment_id,
      gateway_order_id: order_id,
      user: Current.user,
      currency: "INR",
      status: :pending
    )

    # Verify signature
    if payment_method.verify_signature(signature)
      # Fetch amount from Razorpay
      razorpay_payment = payment_method.fetch_from_gateway
      payment_method.amount = razorpay_payment&.amount || 0
      payment_method.signature = signature
      payment_method.status = :paid
      payment_method.save!

      # Create Payment record linked to appointment (if appointment_id provided)
      appointment_id = params[:appointment_id] || razorpay_payment.notes&.dig("appointment_id")
      if appointment_id.present?
        appointment = Appointment.find_by(id: appointment_id, user: Current.user)
        if appointment
          # Find or create payment for this appointment
          payment = appointment.payments.find_or_initialize_by(payment_method_id: nil)
          payment.assign_attributes(
            payment_method: payment_method,
            amount: payment_method.amount,
            currency: payment_method.currency,
            status: :paid
          )
          payment.save!
        end
      end

      redirect_to checkout_success_path(transaction_id: payment_id),
                  notice: "Payment successful!"
    else
      redirect_to new_checkout_path, alert: "Payment verification failed"
    end
  rescue StandardError => e
    Rails.logger.error "Payment verification error: #{e.message}"
    redirect_to new_checkout_path, alert: "Payment error: #{e.message}"
  end

  def success
    @transaction_id = params[:transaction_id]
    @payment_method = PaymentMethod.find_by(gateway_transaction_id: @transaction_id)
    @payment = @payment_method&.payments&.first # Get the payment record if exists
  end
end
