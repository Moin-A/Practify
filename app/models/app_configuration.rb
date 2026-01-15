  class AppConfiguration < Practify::Configuration
    preference :some_setting, :string, default: "default_value"

    preference :sidebar_menu_items, :array, default: [
      { name: "Home", icon: "home", path: "/home" },
      { name: "Calendar", icon: "calendar", path: "/calendar" },
      { name: "Clients", icon: "clients", path: "/clients" },
      { name: "Billing", icon: "billing", path: "/billing" },
      { name: "Settings", icon: "settings", path: "/settings" }
    ]


    def roles
      RoleConfiguration.new.tap do |role_configuration|
        role_configuration.assign_permissions "SuperAdmin", [ "Permissions::AdminPermissionSets" ]
        role_configuration.assign_permissions "default", [ "Permissions::AdminPermissionSets" ]
      end
    end
  end
