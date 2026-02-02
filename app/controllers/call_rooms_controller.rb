class CallRoomsController < ApplicationController
  before_action :set_call_room, only: [ :show ]
  before_action :set_appointment, only: [ :new, :create, :show ]


  def new
    @call_room = @appointment.build_call_room(name: "Call Room for Appointment ##{@appointment.id}")
  end

  def create
    @call_room = @appointment.build_call_room
    # @call_room.name = "#{@appointment.publisher.user_profile.first_name} - #{@appointment.subscriber.user_profile.first_name}"
    if @call_room.save
      redirect_to appointment_call_room_path(@appointment, @call_room), notice: "Call room was successfully created."
    else
       render turbo_stream: turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: @call_room.errors.full_messages.to_sentence(words_connector: ", ", two_words_connector: ", ", last_word_connector: ", ") })
    end
  end

  def show
    role = if current_user == @appointment.publisher
             :publisher
    else
             :subscriber
    end

    vonage_service = VonageVideoService.new
    session_id = @appointment.call_room.vonage_session_id
    @token = VonageVideoService.new.generate_token(session_id, role: role)
    @app_id = Rails.application.credentials.dig(:vonage, :app_id)
  end

  private

  def set_call_room
    @call_room = CallRoom.find(params[:id])
  end

  def set_appointment
    @appointment = Appointment.find(params[:appointment_id])
  end

  def call_room_params
    params.require(:call_room).permit(:name, :vonage_session_id)
  end
end
