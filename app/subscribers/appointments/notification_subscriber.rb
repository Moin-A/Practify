module Appointments
  class NotificationSubscriber
    include Singleton
    include Omnes::Subscriber

    handle :appointment_created, with: :send_notifications
    handle :notes_added, with: :send_notifications

    def send_notifications(event)
      appointment = event.payload[:appointment]
      recipients = [ appointment.publisher, appointment.subscriber ].compact

      AppointmentBookedConfirmationNotification.with(appointment: appointment).deliver_later(recipients)
    end
  end
end

 Appointments::NotificationSubscriber.instance.subscribe_to(Practify.bus)
