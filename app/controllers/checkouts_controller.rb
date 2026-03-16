class CheckoutsController < ApplicationController
  before_action :set_slot
  before_action :initialize_service, only: [ :create, :new ]
  attr_reader :slot, :service, :appointment, :calendar

  def new
    result = service.create(gateway: :razorpay)

    if result.is_a?(Hash)
      @order        = result[:order]
      @razorpay_key = result[:key]
      @amount       = @order.amount
    else
      @order = nil
      flash.now[:alert] = result.is_a?(Array) ? result.join(", ") : "Error creating order"
    end

    respond_to do |format|
      format.turbo_stream do
        if @slot.slot_credit.nil?
          render turbo_stream: [
            turbo_stream.update("payment_modal", content_tag(:div, "Please select a package first.", class: "p-4 text-center text-red-600")),
            turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Please Select a package to Book Appointment", type: :alert })
          ]
        else
          render turbo_stream: turbo_stream.replace("payment_modal", template: "checkouts/new", layout: false)
        end
      end
      format.html
    end
  end

  def create
    # Left intact if needed for explicit POSTs
    result = service.create(gateway: :razorpay, amount: (params[:amount] || 15_000).to_i)
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

    Rails.logger.info "[Razorpay] Verifying payment - Order: #{order_id}, Payment: #{payment_id}"

    gateway = ActiveMerchant::Billing::Razorpay.new(test: Rails.env.development?)
    if gateway.verify_signature(order_id, payment_id, signature) && create_appointment
      complete_booking!(payment_id: payment_id, order_id: order_id)
      Rails.logger.info "[Razorpay] Signature verification successful for Order: #{order_id}"
       respond_to do |format|
         format.turbo_stream do
           render turbo_stream: [
             turbo_stream.remove("payment_modal_wrapper"),
             turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Payment successful! Session booked.", type: :notice })
           ]
         end
         format.html { redirect_to root_path, notice: "Payment successful! Session booked." }
       end
    else
      Rails.logger.error "[Razorpay] Signature verification failed for Order: #{order_id}"
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: @service&.errors&.join(", ") || "Payment verification failed", type: :alert })
          ]
        end
        format.html { redirect_to root_path, alert: "Payment verification failed." }
      end
    end
  rescue StandardError => e
    Rails.logger.error "[Razorpay] Checkout verify error: #{e.message}"
    Rails.logger.error e.backtrace.first(10).join("\n")
    redirect_to root_path, alert: "Payment error: #{e.message}"
  end

  private

  def set_slot
    @slot = Slot.find(params[:slot_id])
    @appointment = @slot.appointment
    @calendar = current_user.calendar
    @slot_credit = @slot.slot_credit
  end

  def complete_booking!(payment_id:, order_id:)
    @slot_credit.completed!
    @slot.booked!
    @slot_credit.update!(payment_order_id: order_id)
  end

  def create_appointment
    @service ||= AppointmentCreator.new(slot: slot, appointment_params: { slot_id: slot.id }, current_user: current_user)
    @service.create
  end

  def initialize_service
    @service = PaymentCheckoutService.new(appointment: appointment, current_user: current_user, slot: slot)
  end
end
