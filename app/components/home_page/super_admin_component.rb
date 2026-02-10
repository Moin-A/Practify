module HomePage
  class SuperAdminComponent < ApplicationComponent
    include SlotsHelper
    include DateParsing
    attr_accessor :current_user
    def initialize(current_user: nil)
      @current_user = current_user
      @calendar = current_user.calendar
      @appointment = current_user.appointments
            .joins(:slot)
            .includes(publisher: :user_profile)
            .pending_or_in_progress_or_completed_or_booked
            .where("slots.start_at >= ?", Time.now.beginning_of_day)
            .order("slots.start_at ASC")
            .first
      @upcoming_appointment = current_user.appointments
            .joins(:slot)
            .pending
            .includes(publisher: :user_profile)
            .where("slots.start_at >= ?", next_day.beginning_of_day)
            .order("slots.start_at ASC")
            .first
    end

    def component
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
  end
end
