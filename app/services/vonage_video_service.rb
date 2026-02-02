# app/services/vonage_video_service.rb
class VonageVideoService
    def initialize
      @client = Vonage::Client.new(
        application_id: Rails.application.credentials.dig(:vonage, :app_id),
        private_key: Rails.application.credentials.dig(:vonage, :private_key)
      )
    end

    def create_session
      # media_mode: :routed is recommended for better stability and recording
      @client.video.create_session(media_mode: :routed).session_id
    end

    def generate_token(session_id, role: :publisher)
      @client.video.generate_client_token(
        session_id: session_id,
        role: :publisher.to_s,
        expire_time: (Time.now + 24.hours).to_i # Optional: explicitly set expiry
      )
    end
end
