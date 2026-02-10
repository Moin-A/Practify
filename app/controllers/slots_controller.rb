class SlotsController < ApplicationController
  before_action :set_calendar
  load_and_authorize_resource only: [ :show, :edit, :update, :confirm  ]
  before_action :authorize_calendar_for_slot_actions, only: [ :create, :new ]

  def index
    @slots = @calendar.slots
  end

  def show
  end

  def new
    @slot = @calendar.slots.build
  end

  def create
    @slot = @calendar.slots.build(slot_params)

    respond_to do |format|
      if @slot.save
        @slots = @calendar.slots_for_date(@slot.start_at.to_date)
        @date = @slot.start_at.to_date
        @selected_slot_id = params[:selected_slot_id]
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("slots_list", partial: "schedules/slot_list", locals: { slots: @slots, calendar: @calendar, date: @date, selected_slot_id: @selected_slot_id }),
            turbo_stream.update("current_date", @slot.start_at.strftime("%A, %B %d, %Y")),
            turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Slot was successfully created!", type: :notice }),
            turbo_stream.update("new_slot_form", "")
          ]
        end
      else


        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: @slot.errors.full_messages.to_sentence(words_connector: ", ", two_words_connector: ", ", last_word_connector: ", "), type: :alert }),
            turbo_stream.update("new_slot_form", "")
          ], status: :unprocessable_entity
        end
      end
    end
  end

  def confirm
    @slot = Slot.find(confirm_params_params[:id])


    if @slot.status_changed? && @slot.errors.empty?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Slot was successfully confirmed!", type: :notice })
          ], status: :ok
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Slot is already booked!", type: :alert })
          ], status: :unprocessable_entity
        end
      end
    end
  end

  def edit
  end

  def update
    if @slot.update(slot_params)
      redirect_to calendar_slot_path(@calendar, @slot), notice: "Slot was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @slot = Slot.find(params[:id])
    authorize! :destroy, @slot, message: "The Slot is already booked or in progress"
    slot_date = @slot.start_at.to_date
    slot_id = @slot.id
    @selected_slot_id = params[:selected_slot_id] || params.dig(:appointment, :slot_id)
    @selected_slot_id = nil if @selected_slot_id.present? && @selected_slot_id.to_s == slot_id.to_s
    @date = slot_date
    @slot.destroy
    @slots = @calendar.slots_for_date(slot_date)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("slots_list", partial: "schedules/slot_list", locals: { slots: @slots, calendar: @calendar, date: @date, selected_slot_id: @selected_slot_id }),
          turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Slot was successfully destroyed!", type: :notice })
        ]
      end
    end
  end

  def release_all_slots
  date = params[:start_date].present? ? params[:start_date].to_date : Date.current
  @slots =@calendar.slots_for_date(date)
  @date = date
  @selected_slot_id = params[:selected_slot_id]

  begin
    @slots.map { |slot| slot.available! unless slot.available? }.any?
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("slots_list", partial: "schedules/slot_list", locals: { slots: @slots, calendar: @calendar, date: @date, selected_slot_id: @selected_slot_id }),
          turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "All slots were successfully released!", type: :notice })
        ]
      end
    end

  rescue => e
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: e.message, type: :alert })
        ]
      end
    end
  end
end


  private

  def set_calendar
    @calendar = current_user.calendar
    # Verify the calendar_id matches if provided (for nested routes)
    if params[:calendar_id].present? && @calendar.id.to_s != params[:calendar_id].to_s
      raise ActiveRecord::RecordNotFound, "Calendar not found"
    end
  end

  def authorize_calendar_for_slot_actions
    authorize! :read, @calendar
  end


  def slot_params
    params.require(:slot).permit(:start_at, :end_at, :status, :slot_id)
  end

  def confirm_params_params
    params.permit(:id)
  end

  def parse_and_save_date_query_param
    @date = parse_date_param
  end
end
