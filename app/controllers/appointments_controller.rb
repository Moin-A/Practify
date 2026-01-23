class AppointmentsController < ApplicationController
  include DateParsing
  attr_reader :slot

  before_action :set_appointment, only: [ :show, :edit, :update, :destroy ]
  before_action :set_slot, only: [ :new, :create ]

  def index
    @appointments = current_user.appointments
  end

  def show
    @date = parse_date_param
    @calendar = current_user.calendar
    @slots = @calendar.slots_for_date(@date)
  end

  def new
    @appointment = @slot.build_appointment(user: current_user) if @slot
  end

  def create
    creator = AppointmentCreator.new(
      slot: slot,
      appointment_params: appointment_params
    )

    if creator.create
      redirect_to appointment_path(creator.appointment), notice: "Appointment was successfully created."
    else
      @appointment = creator.appointment
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @appointment.update(appointment_params)
      redirect_to @appointment, notice: "Appointment was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
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
    params.require(:appointment).permit(:notes, :slot_id)
  end
end
