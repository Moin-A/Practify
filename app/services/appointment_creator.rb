class AppointmentCreator
  attr_reader :appointment_params, :slot, :errors
  def initialize(slot:, appointment_params: {})
    @appointment_params = appointment_params
    @slot = slot
    @errors = []
  end

  def create
    return errors unless valid?

    @appointment = slot.build_appointment(appointment_params)
    @appointment.save
  end

  def valid?
    validate_duplicate_appointment
    errors.empty?
  end

  private



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

  def validate_duplicate_appointment
    if slot.appointment.present?
      errors << "Appointment already exists for this slot"
    end
  end
end
