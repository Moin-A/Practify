class AppointmentReminderNotification < ApplicationNotification
  # deliver_by :email, mailer: "AppointmentMailer", method: :reminder

  required_param :appointment

  def appointment
    params[:appointment]
  end

  def title
    "Reminder for your upcoming appointment"
  end

  # def url
  #   appointment_url(appointment)
  # end
end
