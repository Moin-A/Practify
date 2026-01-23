class CalendarManager
  def self.ensure_user_calendar(user)
    user.calendar || create_default_calendar(user)
  end

  def self.create_default_calendar(user)
    user.create_calendar!(
      timezone: Time.zone.name,
      name: "Default Calendar"
    )
  end
end