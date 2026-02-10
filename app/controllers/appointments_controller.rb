class AppointmentsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  load_and_authorize_resource
  include DateParsing
  attr_reader :slot

  before_action :set_appointment, only: [ :show, :update, :destroy, :has_joined ]
  before_action :set_slot, only: [ :new, :create ]


  def index
    @appointments = current_user.appointments
    render json: @appointments
  end

  def show
    @date = parse_date_param
    @calendar = current_user.calendar
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

  private


  def set_slot
    @slot = Slot.find(appointment_params[:slot_id])
  end

  def set_appointment
    @appointment = current_user.appointments.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(:slot_id)
  end

  def record_not_found
    respond_to do |format|
      format.html { redirect_to appointments_path, alert: "Appointment not found" }
      format.json { render json: { error: "Appointment not found" }, status: :unprocessable_entity }
      format.turbo_stream { render turbo_stream: [ turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Appointment not found", type: :alert }) ], status: :unprocessable_entity }
    end
  end
end
