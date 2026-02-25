module HomePage
  class SuperAdminComponent < ApplicationComponent
    include SlotsHelper
    include DateParsing
    attr_accessor :current_user, :todays_appointment_list
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
      @todays_appointment_list = Appointment
                                .joins(:slot)
                                .includes(:slot, user: :user_profile)
                                .active
                                .where(
                                  "slots.start_at >= ? AND slots.end_at <= ? AND publisher_id = ?",
                                  Time.current.beginning_of_day,
                                  Time.current.end_of_day,
                                  current_user.id
                                ).order("slots.start_at")

      @users_with_pending_notes = User.joins(:appointments)
                                      .joins("INNER JOIN notes ON notes.notable_id = users.id AND notes.notable_type = 'User' AND notes.category = 'note'")
                                      .where(appointments: { status: "completed" })
                                      .group("users.id")
                                      .having("MAX(appointments.created_at) > MAX(notes.created_at)")
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
