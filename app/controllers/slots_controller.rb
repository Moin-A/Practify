class SlotsController < ApplicationController
  before_action :set_slot, only: [ :show, :edit, :update, :destroy ]
  before_action :set_calendar

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

    if @slot.save
      redirect_to calendar_slot_path(@calendar, @slot), notice: "Slot was successfully created."
    else
      render :new, status: :unprocessable_entity
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
    @slot.destroy
    redirect_to calendar_slots_path(@calendar), notice: "Slot was successfully destroyed."
  end

  private

  def set_calendar
    @calendar = current_user.calendars.find(params[:calendar_id])
  end

  def set_slot
    @slot = @calendar.slots.find(params[:id])
  end

  def slot_params
    params.require(:slot).permit(:start_at, :end_at, :status)
  end
end
