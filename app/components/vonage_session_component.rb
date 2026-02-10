class VonageSessionComponent < ApplicationComponent
  def initialize(call_room:, token:, app_id:, current_user:, appointment_id:, session_id:)
    @call_room = call_room
    @token = token
    @app_id = app_id
    @current_user = current_user
    @appointment_id = appointment_id
    @session_id = session_id
  end

  private

  attr_reader :call_room, :token, :app_id, :current_user, :appointment_id, :session_id
end
