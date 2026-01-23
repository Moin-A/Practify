class AppointmentCreator
  attr_reader :appointment_params, :slot
  def initialize(slot:, appointment_params: {})
    @appointment_params = appointment_params
    @slot = slot
  end

  def create
    return false unless slot_available?

    @appointment = slot.build_appointment(appointment_params)
    @appointment.save
  end

  def appointment
    @appointment
  end

  def errors
    @appointment&.errors || []
  end

  private


  def slot_available?
    slot&.available?
  end
end
