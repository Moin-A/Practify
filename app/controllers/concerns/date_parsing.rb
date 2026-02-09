module DateParsing
  extend ActiveSupport::Concern

  private

  def parse_date_param(param_key = :start_date)
    params[param_key].present? ? Date.parse(params[param_key]) : Date.current
  end

  def next_day
    @next_day ||= Time.current + 1.day
  end
end
