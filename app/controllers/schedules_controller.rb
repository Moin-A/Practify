class SchedulesController < ApplicationController
  include DateParsing

  def show
    @date = parse_date_param
    @calendar = current_user.calendar
    @slots = @calendar.slots_for_date(@date)
    @meetings = @calendar.appointments_for_date(@date)
  end
end
