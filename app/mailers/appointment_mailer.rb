class AppointmentMailer < ApplicationMailer
  def booked_confirmation
    @notification = params[:notification]
    @appointment = params[:appointment]
    @recipient = params[:recipient]

    mail(
      to: @recipient.email_address,
      subject: "Appointment booked confirmation"
    )
  end
end
