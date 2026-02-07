module HomePage
 include DateParsing
 class ClientComponent < ApplicationComponent
  attr_reader :current_user, :selected_slot_id
  def initialize(current_user: nil, selected_slot_id: nil)
    @current_user = current_user
    @calendar = current_user.calendar
    @selected_slot_id = selected_slot_id
    @appointment = current_user.appointments
                                .joins(:slot)
                                .includes(publisher: :user_profile)
                                .where("slots.start_at >= ?", Time.current)
                                .order("slots.start_at ASC")
                                .first
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

  def next_day
    @next_day ||= Time.current + 1.day
  end



  def next_day_available_slots
    slots = Slot.where(start_at: next_day.beginning_of_day..next_day.end_of_day)
                    .where(status: :available).available
                    .order(start_at: :asc)
    slots.map { |slot| { time: slot.start_at.strftime("%I:%M %p"), id: slot.id } }
  end

  def selected_slot
    return nil unless selected_slot_id
    Slot.find_by(id: selected_slot_id)
  end

  def appointment_created?(slot_id)
    slot = Slot.find_by(id: slot_id)
    slot.present? && slot.appointment.present?
  end


  def slot_selected?(slot_id)
    selected_slot_id.to_s == slot_id.to_s
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
 end
end
