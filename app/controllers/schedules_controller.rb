class SchedulesController < ApplicationController
  include DateParsing
  before_action :set_calendar
  before_action :authorize_calendar

  def show
    @date = parse_date_param
    @slots = Slot.available_on(@date).includes(:appointment)
    @meetings = @calendar.appointments_for_date(@date)
    @selected_slot_id = params[:selected_slot_id] || nil
  end




  def set_calendar
    @calendar = Calendar.find(params[:calendar_id])
  end

  def authorize_calendar
    authorize! :read, @calendar, message: "You are not authorized to access this calendar"
  end
end
