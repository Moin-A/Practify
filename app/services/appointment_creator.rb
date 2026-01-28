class AppointmentCreator
  attr_reader :appointment_params, :slot, :errors, :current_user
  def initialize(slot:, appointment_params: {}, current_user: nil)
    @appointment_params = appointment_params
    @slot = slot
    @current_user = current_user || appointment_params[:user]
    @errors = []
  end

  def create
    return false unless valid?
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



  private


  def slot_available?
    slot&.available?
  end



  def validate_duplicate_appointment
    if slot.appointment.present?
      if current_user && slot.appointment.user_id != current_user.id
        errors << "Appointment booked by another user"
      else
        errors << "Appointment already exists for this slot"
      end
    end
  end
end
