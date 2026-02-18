# Disable STI for Noticed notifications
Rails.application.config.to_prepare do
Noticed::Notification.inheritance_column = :_type_disabled
end
