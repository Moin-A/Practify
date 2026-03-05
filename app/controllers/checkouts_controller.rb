class CheckoutsController < ApplicationController
  before_action :set_appointment
  before_action :initialize_service, only: :new
  attr_reader :appointment, :service

  def new
   result = service.create(gateway: :razorpay, amount: (params[:amount] || 10_000).to_i)

   if result.is_a?(Hash)
    @order        = result[:order]
    @razorpay_key = result[:key]
    @amount       = @order.amount
   else
    @order = nil
    flash.now[:alert] = result.join(", ")
   end
    
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
      redirect_to root_path, notice: "Payment successful! Payment ID: #{payment_id}"
    else
      redirect_to new_appointment_checkout_path(@appointment), alert: "Payment verification failed."
    end
  rescue StandardError => e
    Rails.logger.error "Checkout verify error: #{e.message}"
    redirect_to new_appointment_checkout_path(@appointment), alert: "Payment error: #{e.message}"
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:appointment_id])
  end

  def initialize_service
    @service = PaymentCheckoutService.new(appointment: appointment, current_user: current_user)
  end
end

