class AppointmentResheduleService
  attr_reader :errors

  def initialize(appointment:, slot:, new_slot:, appointment_params:)
    @appointment = appointment
    @slot = slot
    @new_slot = new_slot
    @appointment_params = appointment_params
    @errors = []
  end

  # Public entry point. Returns true on success, false otherwise.
  def call
    return false unless valid?

    ActiveRecord::Base.transaction do
      @appointment.update!(slot: @new_slot)
    end
    true
  rescue => e
    @errors << e.message
    false
  end

  private

  # Ensure the new slot exists and is available.
  def valid?
    if @new_slot.nil?
      @errors << "No slot selected for reschedule"
      return false
    end
    validate_slot_available
  end

  def validate_slot_available
    if @new_slot.respond_to?(:available?) && @new_slot.available?
      true
    else
      @errors << "Selected slot is not available"
      false
    end
  end
end
