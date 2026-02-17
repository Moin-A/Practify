class AppointmentBookedConfirmationNotification < ApplicationNotification
  deliver_by :email, mailer: "AppointmentConfirmationMailer", method: :booked_confirmation

  # Optional: Store in database too
  deliver_by :database

  required_param :appointment

  def title
    "Appointment booked confirmation"
  end
end
