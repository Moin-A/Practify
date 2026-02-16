module Appointments
  class NotificationSubscriber
    include Omnes::Subscriber

    handle :appointment_created, with: :send_notifications

    def send_notifications(event)
      appointment = event.payload[:appointment]
      recipients = [appointment.publisher, appointment.subscriber].compact
      
      AppointmentReminderNotification.with(appointment: appointment).deliver_later(recipients)
    end
  end
end

 Appointments::NotificationSubscriber.new.subscribe_to(Practify.bus)