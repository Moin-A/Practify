module HomePage
 class ClientComponent < ApplicationComponent
  include SlotsHelper, CalendarHelper
  attr_reader :current_user, :selected_slot_id
  def initialize(current_user: nil, selected_slot_id: nil)
    @current_user = current_user
    @calendar = current_user.calendar
    @selected_slot_id = selected_slot_id
    @appointment = current_user.appointments
                                .joins(:slot)
                                .includes(publisher: :user_profile)
                                .pending_or_in_progress_or_completed_or_booked
                                .where("slots.start_at >= ?", Time.now.beginning_of_day)
                                .order("slots.start_at ASC")
                                .first
   @upcoming_appointment = current_user.appointments
                                .joins(:slot)
                                .booked
                                .includes(publisher: :user_profile)
                                .where("slots.start_at >= ?", next_day.beginning_of_day)
                                .order("slots.start_at ASC")
                                .first
  @notifications = current_user.notifications.unread.where(type: "BroadcastNotesAdded::Notification")
  end

  def render?
    @current_user.present?
  end

  def user_profile
    current_user.user_profile
  end

  def grettings
    case Time.now.hour
    when 0..10
      "Good Morning"
    when 11..15
       "Good Afternoon"
    when 16..23
      "Good Evening"
    else
      "Good day"
    end
  end

  def title
    "#{grettings}, #{user_profile.first_name} #{user_profile.last_name}"
  end

  def avatar
    user_profile.avatar.attached? ? user_profile.avatar : "https://ui-avatars.com/api/?name=#{user_profile.first_name}+#{user_profile.last_name}"
  end

  def doctor_profile
    return nil unless @appointment&.publisher&.user_profile
    @appointment.publisher.user_profile
  end

  def doctor_name
    return nil unless doctor_profile&.first_name&.present? && doctor_profile&.last_name&.present?
    "Dr. #{doctor_profile.first_name} #{doctor_profile.last_name}"
  end

  def doctor_title
    return nil unless doctor_profile
    doctor_profile.professional_info&.dig("title") || "Licensed Therapist"
  end

  def doctor_initials
    return nil unless doctor_profile&.first_name&.present? && doctor_profile&.last_name&.present?
    "#{doctor_profile.first_name[0]}#{doctor_profile.last_name[0]}".upcase
  end

  def appointment_date
    return nil unless @appointment&.slot&.start_at
    @appointment.slot.start_at.strftime("%A, %b %d")
  end

  def appointment_time
    return nil unless @appointment&.slot&.start_at
    @appointment.slot.start_at.strftime("%I:%M %p")
  end

  def sessions_completed_percentage
    completed = current_user.appointments.completed.count
    remaining = SlotCredit
      .joins(slot: :appointment)
      .where(appointments: { user_id: current_user.id })
      .where(payment_status: :completed)
      .sum(:slot_remaining)
    total = completed + remaining
    return 0 if total.zero?
    [(completed.to_f / total * 100).round, 100].min
  end
 end
end
