class PostCallHeartBeatJob < ApplicationJob
  queue_as :default

  def perform
     all_appointments = Appointment.includes(:slot).pending

     all_appointments.each do |appointment|
      updated_appointment_status(appointment)
     end
  end

  private

  def updated_appointment_status(appointment)
    return if appointment.slot.nil? || appointment.start_at > Time.now
    if in_progress?(appointment)
      appointment.update(status: :in_progress)
    elsif both_joined?(appointment)
      appointment.update(status: :completed)
    elsif neither_joined?(appointment)
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
    appointment.end_at >= Time.now && appointment.start_at <= Time.now
  end
end
