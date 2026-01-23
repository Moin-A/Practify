class AppointmentCreator
  def initialize(slot_id:, user:, appointment_params: {})
    @slot_id = slot_id
    @user = user
    @appointment_params = appointment_params
  end

  def create
    return false unless slot_available?

    @appointment = slot.build_appointment(@appointment_params.merge(user: @user))
    @appointment.save
  end

  def appointment
    @appointment
  end

  def errors
    @appointment&.errors || []
  end

  private

  def slot
    @slot ||= Slot.find_by(id: @slot_id)
  end

  def slot_available?
    slot&.available?
  end
end