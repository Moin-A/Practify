class SchedulesController < ApplicationController
  include DateParsing
  before_action :set_calendar
  before_action :authorize_calendar

  def show
    @date = parse_date_param
    @slots = @calendar.slots_for_date(@date)
    @meetings = @calendar.appointments_for_date(@date)
  end


  private

  def set_calendar
    @calendar = Calendar.find(params[:calendar_id])
  end

  def authorize_calendar
    authorize! :read, @calendar, message: "You are not authorized to access this calendar"
  end
end
