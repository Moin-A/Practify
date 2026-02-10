class CallRoomSessionCreator
  attr_reader :appointment, :current_user, :errors, :role, :session_id, :token, :app_id

  def initialize(appointment:)
    @appointment = appointment
    @current_user = Current.session.user
    @errors = []
  end

  def create
    return nil unless valid?

    @role = determine_role
    @session_id = @appointment.call_room.vonage_session_id
    @token = VonageVideoService.new.generate_token(@session_id, role: @role)
    @app_id = Rails.application.credentials.dig(:vonage, :app_id)

    {
      token: token,
      app_id: app_id,
      role: role,
      session_id: session_id
    }
  end

  def valid?
    validate_authorization
    validate_timing
    validate_call_room_exists
    validate_session_not_expired
    errors.empty?
  end

  def error_message
    errors.first
  end

  private

  def validate_authorization
    unless @current_user == @appointment.publisher || @current_user == @appointment.subscriber
      errors << "You are not authorized to access this call room."
    end
  end

  def validate_session_not_expired
    unless Time.current < @appointment.end_at
      errors << "Call room session has expired."
    end
  end

  def validate_timing
    unless Time.current + 10.minutes > @appointment.start_at
      errors << "please wait, the session has still time to start, you can join at #{(@appointment.start_at - 10.minutes).strftime("%B %d, %Y at %I:%M %p")}"
    end
  end

  def validate_call_room_exists
    unless @appointment.call_room
      errors << "Call room has not been created yet."
    end
  end

  def determine_role
    @current_user == @appointment.publisher ? :publisher : :subscriber
  end
end
