class CallRoom < ApplicationRecord
  belongs_to :appointment
  delegate :start_at, :end_at, :status, :user, :publisher, :subscriber, to: :appointment
  before_create :set_vonage_session_id
  after_initialize :set_name

  validates :name, presence: true
  validates :vonage_session_id, uniqueness: true, allow_nil: true

  def formatted_start_time
    return "N/A" unless start_at
    start_at.strftime("%B %d, %Y at %I:%M %p")
  end

  def formatted_end_time
    return "N/A" unless end_at
    end_at.strftime("%B %d, %Y at %I:%M %p")
  end

  def session_duration
    return "N/A" unless start_at && end_at
    duration_minutes = ((end_at - start_at) / 60).to_i
    "#{duration_minutes} minutes"
  end

  def can_start_session?
    return false unless start_at
    # Allow starting 15 minutes before the appointment time
    Time.current >= (start_at - 15.minutes) &&
    Time.current <= (end_at || start_at + 1.hour)
  end

  def is_session_active?
    return false unless start_at && end_at
    Time.current >= start_at && Time.current <= end_at
  end

  def video_call_room_id
    vonage_session_id || "room-#{id}-#{appointment.slot_id}"
  end
  private
  def set_vonage_session_id
    # client = Vonage::Client.new(application_id: Rails.application.credentials.VONAGE_APPLICATION_ID, application_key: Rails.application.credentials.VONAGE_APPLICATION_KEY)
    self.vonage_session_id = Rails.application.credentials.vonage.session_id
    self.name = "#{appointment.publisher.user_profile.first_name} - #{appointment.subscriber.user_profile.first_name}"
  end

  def set_name
    return if name.present?
    self.name = "#{appointment.publisher.user_profile.first_name} - #{appointment.subscriber.user_profile.first_name}"
  end
end
