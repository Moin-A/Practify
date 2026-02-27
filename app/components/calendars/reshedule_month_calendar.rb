module Calendars
  class ResheduleMonthCalendar < Base
    def url_for_previous_view
       view_context.url_for(@params.merge(start_date_param => (date_range.first - 1.day).iso8601))
    end

    def date_range
      (start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week).to_a
    end



    def url_for_checked_date(date)
      view_context.url_for(@params.merge(start_date_param => date.iso8601))
    end

    def url_for_event(event)
      url_for_event(event)
    end
  end
end
