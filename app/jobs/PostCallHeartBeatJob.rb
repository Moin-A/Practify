class PostCallHeartBeatJob < ApplicationJob
  queue_as :default

  def perform
     all_appointments = Appointment.includes(:slot).pending_or_in_progress_or_completed_or_booked

     all_appointments.each do |appointment|
      updated_appointment_status(appointment)
     end
  end

  private

  def updated_appointment_status(appointment)
    return if appointment.slot.nil? ||  Time.now < appointment.start_at
    if appointment.in_progress? && Time.now > appointment.end_at
      appointment.update(status: :completed)
    elsif appointment.booked? &&  Time.now  > appointment.end_at
      appointment.update(status: :completed)
    elsif meeting_in_progress?(appointment) && appointment.publisher_or_subscriber_joined?
      appointment.update(status: :in_progress)
    elsif both_joined?(appointment)
      appointment.update(status: :completed)
    elsif neither_joined?(appointment) && Time.now > appointment.end_at
      appointment.update(status: :noshow)
    end
  end


  def both_joined?(appointment)
    appointment.publisher_joined && appointment.subscriber_joined
  end

  def neither_joined?(appointment)
    !appointment.publisher_joined && !appointment.subscriber_joined
  end

  def in_progress?(appointment)
    appointment.start_at <= Time.now && appointment.end_at >= Time.now
  end
end
