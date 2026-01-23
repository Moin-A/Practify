class SlotsController < ApplicationController
  before_action :set_calendar, only: [ :create, :new, :index ]
  before_action :set_slot, only: [ :show, :edit, :update, :destroy ]

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
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.prepend("slots_list", partial: "schedules/slot_row", locals: { slot: @slot }),
            turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Slot was successfully created!", type: :notice }),
            turbo_stream.update("new_slot_form", "")
          ]
        end
      else
        format.html { render :new, status: :unprocessable_entity }
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

  private

  def set_calendar
    @calendar = current_user.calendar
    # Verify the calendar_id matches if provided (for nested routes)
    if params[:calendar_id].present? && @calendar.id.to_s != params[:calendar_id].to_s
      raise ActiveRecord::RecordNotFound, "Calendar not found"
    end
  end
  

  def set_slot
    @calendar = current_user.calendar
    @slot = @calendar.slots.find(params[:id])
  end

  def slot_params
    params.require(:slot).permit(:start_at, :end_at, :status)
  end
end
