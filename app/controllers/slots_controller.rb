class SlotsController < ApplicationController
  before_action :set_calendar
  load_and_authorize_resource through: :calendar, only: [ :show, :edit, :update, :destroy ]
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
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("slots_list", partial: "schedules/slot_list", locals: { slots: @slots }),
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
          ]
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
    start_date = params[:start_date]
    @slot.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Slot was successfully destroyed!", type: :notice }),
          turbo_stream.remove("slot_#{@slot.id}")
        ]
      end
    end
  end

  def release_all_slots
  @slots =@calendar.slots_for_date(params[:start_date].to_date)

  begin
    @slots.map { |slot| slot.available! unless slot.available? }.any?
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("slots_list", partial: "schedules/slot_list", locals: { slots: @slots }),
          turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "All slots were successfully released!", type: :notice })
        ]
      end
    end

  rescue => e
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: e.message.split(":")[1].strip, type: :alert })
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
    params.require(:slot).permit(:start_at, :end_at, :status)
  end
end
