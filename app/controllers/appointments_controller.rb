class AppointmentsController < ApplicationController
rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
load_and_authorize_resource
include DateParsing
attr_reader :slot, :calendar

before_action :set_appointment, only: [ :show, :update, :destroy, :has_joined ]
before_action :set_slot, only: [ :new, :create, :require_payment ]
before_action :set_calendar, only: [ :show, :create, :new, :require_payment ]
around_action :with_slot_mutex, only: [ :require_payment ]


def index
  @appointments = current_user.appointments
  render json: @appointments
end

def show
  @date = parse_date_param
  @slots = @calendar.slots_for_date(@date)
  @selected_slot_id = params[:selected_slot_id] || nil
end

def new
  @appointment = @slot.build_appointment(user: current_user) if @slot
end

def create
  creator = AppointmentCreator.new(
    slot: slot,
    appointment_params: appointment_params.merge(user: current_user),
    current_user: current_user
  )

  respond_to do |format|
    format.turbo_stream do
      if creator.create
        render turbo_stream: [ turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Appointment was successfully created.", type: :notice }) ]
      else
        render turbo_stream: [
          turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: creator.errors.join(", "), type: :alert })
        ], status: :unprocessable_entity
      end
    end
  end
end

def has_joined
  @appointment.update_joined_status
  if @appointment.save
    render json: { message: "Publisher joined the appointment" }
  else
    render json: { message: @appointment.errors.full_messages.join(", ") }, status: :unprocessable_entity
  end
end

def update
  if @appointment.update(appointment_params)
    redirect_to @appointment, notice: "Appointment was successfully updated."
  else
    render :edit, status: :unprocessable_entity
  end
end

def edit
  @appointment = current_user.appointments.find(params[:id])
  render json: @appointment
end

def destroy
  @appointment.destroy
  redirect_to appointments_url, notice: "Appointment was successfully destroyed."
end


def reshedule
  new_slot = Slot.find_by(id: appointment_params[:reschedule_selected_slot_id])
  reshedule_service = AppointmentResheduleService.new(appointment: @appointment, slot: @appointment.slot, new_slot: new_slot, appointment_params: appointment_params)

  respond_to do |format|
    format.turbo_stream do
      if reshedule_service.call
        render turbo_stream: [ turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Appointment was successfully rescheduled.", type: :notice }) ]
      else
        render turbo_stream: [
          turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: reshedule_service.errors.join(", "), type: :alert })
        ], status: :unprocessable_entity
      end
    end
  end
end

  def require_payment
    respond_to do |format|
      format.turbo_stream do
        if @slot.appointment.present?
          render turbo_stream: [
            turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Appointment already exists for this slot", type: :alert })
          ]
        else
          render turbo_stream: [
            turbo_stream.replace("new_slot_form", partial: "slot_credits/packages", locals: { slot: @slot, calendar: @calendar, appointment: @slot.build_appointment })
          ]
        end
      end
    end
end



private

def set_slot
  @slot = Slot.find(appointment_params[:slot_id])
end

def set_appointment
  @appointment = current_user.appointments.find(params[:id])
end

def appointment_params
  params.require(:appointment).permit(:slot_id, :reschedule_selected_slot_id)
end

def set_calendar
   @calendar ||= current_user.calendar
end

def with_slot_mutex
  SlotMutex.with_lock!(slot) { yield }
rescue SlotMutex::LockFailed => e
  retry if (attempt ||= 0) < 1 && (attempt += 1)
  render turbo_stream: [
    turbo_stream.remove("payment_modal_wrapper"),
    turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Slot is already booked by another user.", type: :alert })
  ]
end

def record_not_found
  respond_to do |format|
    format.html { redirect_to appointments_path, alert: "Appointment not found" }
    format.json { render json: { error: "Appointment not found" }, status: :unprocessable_entity }
    format.turbo_stream { render turbo_stream: [ turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Appointment not found", type: :alert }) ], status: :unprocessable_entity }
  end
end
end
