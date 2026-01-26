class AppointmentCreator
  attr_reader :appointment_params, :slot, :appointment
  
  def initialize(slot:, appointment_params: {})
    @appointment_params = appointment_params
    @slot = slot
    @errors = []
    @appointment = nil
  end

  def errors
    @errors
  end

  def create
    return false unless valid?

    ActiveRecord::Base.transaction do
      @appointment = slot.build_appointment(appointment_params)
      # Payment is initialized but won't be saved (autosave: false)
      # It will be saved later when payment_method is added during checkout
      if @appointment.save
        slot.update_column(:status, Slot.statuses[:booked])
        true
      else
        @errors.concat(@appointment.errors.full_messages)
        false
      end
    end
  rescue StandardError => e
    @errors << e.message
    false
  end

  def valid?
    validate_duplicate_appointment
    validate_slot_available
    @errors.empty?
  end

  private

  def validate_duplicate_appointment
    if slot.appointment.present?
      @errors << "Appointment already exists for this slot"
    end
  end

  def validate_slot_available
    unless slot&.available?
      @errors << "Slot is not available"
    end
  end
end
