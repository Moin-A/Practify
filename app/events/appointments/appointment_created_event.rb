module Appointments
  class AppointmentCreatedEvent
    include Omnes::Event

    attr_reader :appointment, :recipients
    alias_method :payload, :itself # So that event.payload[:record] works if we want, or we can just use getters

    def initialize(appointment:, recipients: [])
      @appointment = appointment
      @recipients = recipients
    end

    def payload
      { record: appointment, recipients: recipients }
    end

    def omnes_event_name
      :appointment_created
    end
  end
end
