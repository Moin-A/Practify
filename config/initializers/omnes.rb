Rails.application.config.to_prepare do
  Practify.bus do |bus|
    bus.register(:appointment_created) unless bus.registry.registrations.map(&:event_name).include?(:appointment_created)
  end
end
