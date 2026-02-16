class AppointmentCreator
  attr_reader :appointment_params, :slot, :errors, :current_user, :appointment
  def initialize(slot:, appointment_params: {}, current_user: nil)
    @appointment_params = appointment_params
    @slot = slot
    @current_user = current_user || appointment_params[:user]
    @errors = []
  end

  def create
    return false unless valid?
    @appointment = slot.build_appointment(appointment_params.merge(publisher: slot.user, subscriber: current_user))
    if @appointment.save_and_notify
      true
    else
      errors << @appointment.errors.full_messages.to_sentence(words_connector: ", ", two_words_connector: ", ", last_word_connector: ", ")
      false
    end
  end

  def valid?
    validate_duplicate_appointment
    validate_appointment_already_exists
    errors.empty?
  end

  private

  def validate_appointment_already_exists
    # #need to check if the appointment is already booked by the current user in same date as @slot.start_at
    if current_user.appointments.joins(:slot).exists?(slots: { start_at: slot.start_at.beginning_of_day..slot.end_at.end_of_day })
    errors << "Appointment already exists for this date"
    end
  end


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
