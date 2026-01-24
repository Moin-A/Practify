module HomePage
 include DateParsing
 class ClientComponent < ApplicationComponent
  attr_reader :current_user
  def initialize(current_user: nil)
    @current_user = current_user
    @calendar = current_user.calendar
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
    Time.current + 1.day
  end

  def next_day_available_slots
    slots = Slot.where(start_at: next_day.beginning_of_day..next_day.end_of_day)
                    .where(status: :available)
                    .order(start_at: :asc)
    slots.map { |slot| { time: slot.start_at.strftime("%I:%M %p"), id: slot.id } }
  end
 end
end
