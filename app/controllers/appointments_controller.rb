class AppointmentsController < ApplicationController
  before_action :set_appointment, only: [ :show, :edit, :update, :destroy ]
  before_action :set_slot, only: [ :new, :create ]

  def index
    @appointments = current_user.appointments
  end

  def show
  end

  def new
    @appointment = @slot.build_appointment(user: current_user) if @slot
  end

  def create
    slot_id = params[:slot_id] || appointment_params[:slot_id]
    @slot = Slot.find(slot_id) if slot_id
    @appointment = @slot&.build_appointment(appointment_params.except(:slot_id).merge(user: current_user))

    if @appointment&.save
      redirect_to appointment_path(@appointment), notice: "Appointment was successfully created."
    else
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
    slot_id = params[:slot_id] || params.dig(:appointment, :slot_id)
    @slot = Slot.find(slot_id) if slot_id
  end

  def set_appointment
    @appointment = current_user.appointments.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(:notes, :slot_id)
  end
end
