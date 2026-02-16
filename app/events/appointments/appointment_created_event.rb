module Appointments
  class AppointmentCreatedEvent
    include Omnes::Event

    attr_reader :appointment

    def initialize(appointment:)
      @appointment = appointment
    end

    def omnes_event_name
      :appointment_created
    end
  end
end
