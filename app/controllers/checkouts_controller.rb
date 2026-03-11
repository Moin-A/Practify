class CheckoutsController < ApplicationController
  before_action :set_slot
  before_action :initialize_service, only: [ :create, :new ]
  attr_reader :slot, :service, :appointment, :calendar

  def new
    result = service.create(gateway: :razorpay, amount: ((@slot.slot_credit.amount || 150) * 100).to_i)

    if result.is_a?(Hash)
      @order        = result[:order]
      @razorpay_key = result[:key]
      @amount       = @order.amount
    else
      @order = nil
      flash.now[:alert] = result.is_a?(Array) ? result.join(", ") : "Error creating order"
    end

    respond_to do |format|
      format.html do
        # Turbo Frame navigation expects the response to include a matching <turbo-frame id="payment_modal">.
        # For non-frame visits, keep the normal full-page render with layout.
        render layout: !turbo_frame_request?
      end
    end
  end

  def create
    # Left intact if needed for explicit POSTs
    result = service.create(gateway: :razorpay, amount: ((@slot.slot_credit.amount || 150) * 100).to_i)

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

  def set_slot
    @slot = Slot.find(params[:slot_id])
    @appointment = @slot.appointment
    @calendar = current_user.calendar
  end

  def initialize_service
    @service = PaymentCheckoutService.new(appointment: appointment, current_user: current_user)
  end
end
