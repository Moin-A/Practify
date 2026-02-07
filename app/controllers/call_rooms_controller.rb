class CallRoomsController < ApplicationController
  before_action :set_call_room, only: [ :show ]
  before_action :set_appointment, only: [ :new, :create, :show ]


  def new
    @call_room = @appointment.build_call_room(name: "Call Room for Appointment ##{@appointment.id}")
  end

  def create
    session_creator = CallRoomSessionCreator.new(appointment: @appointment)
    ActiveRecord::Base.transaction do
     @call_room = @appointment.create_call_room
     raise ActiveRecord::Rollback unless session_creator.create
    end

    # @call_room.name = "#{@appointment.publisher.user_profile.first_name} - #{@appointment.subscriber.user_profile.first_name}"
    if @call_room.persisted?
      redirect_to appointment_call_room_path(@appointment, @call_room), notice: "Call room was successfully created."
    else

      render turbo_stream: turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: [ @call_room.errors.full_messages, session_creator.error_message ].flatten.join(", ") })
    end
  end

  def show
    # Authorization check - ensure user is part of this appointment

    session_creator = CallRoomSessionCreator.new(appointment: @appointment)
    if session_creator.create
      @token = session_creator.token
      @app_id = session_creator.app_id
      @role = session_creator.role
      @session_id = session_creator.session_id
    else
      render turbo_stream: turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: session_creator.error_message })
    end
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
