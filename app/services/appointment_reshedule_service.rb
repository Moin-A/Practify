class AppointmentResheduleService
    def initialize(appointment)
        @appointment = appointment
    end

    def call
        raise NotImplementedError
    end
end
