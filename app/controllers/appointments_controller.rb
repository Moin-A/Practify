class AppointmentsController < ApplicationController
  include DateParsing
  attr_reader :slot

  before_action :set_appointment, only: [ :show, :edit, :update, :destroy ]
  before_action :set_slot, only: [ :new, :create ]
  before_action :load_and_authorize_appointment, only: [ :show, :edit, :update, :destroy ]

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
    return head :unprocessable_entity unless slot

    authorize! :create, Appointment

    creator = AppointmentCreator.new(
      slot: slot,
      appointment_params: appointment_params.merge(user: current_user)
    )

    respond_to do |format|
      if creator.create
        @appointment = creator.appointment
        format.html { redirect_to appointment_path(@appointment), notice: "Appointment was successfully created." }
        format.turbo_stream
      else
        @appointment = creator.appointment || Appointment.new
        @errors = creator.errors
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :create, status: :unprocessable_entity }
      end
    end
  end


  def edit
    # Edit action for CanCanCan compatibility
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

  def load_and_authorize_appointment
    authorize! :manage, @appointment
  end

  def set_slot
    slot_id = params.dig(:appointment, :slot_id) || params[:slot_id]
    @slot = Slot.find(slot_id) if slot_id.present?
  end

  def set_appointment
    @appointment = current_user.appointments.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(:notes, :slot_id)
  end
end
