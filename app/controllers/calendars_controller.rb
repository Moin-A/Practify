class CalendarsController < ApplicationController
  before_action :set_calendar, only: [ :show, :edit, :update, :destroy ]

  def index
    @calendars = current_user.calendars
  end

  def show
  end

  def new
    @calendar = current_user.calendars.build
  end

  def create
    @calendar = current_user.calendars.build(calendar_params)

    if @calendar.save
      redirect_to @calendar, notice: "Calendar was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @calendar.update(calendar_params)
      redirect_to @calendar, notice: "Calendar was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @calendar.destroy
    redirect_to calendars_url, notice: "Calendar was successfully destroyed."
  end

  private

  def set_calendar
    @calendar = current_user.calendars.find(params[:id])
  end

  def calendar_params
    params.require(:calendar).permit(:name, :timezone)
  end
end
