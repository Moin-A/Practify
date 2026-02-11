  class AppConfiguration < Practify::Configuration
    preference :some_setting, :string, default: "default_value"

    preference :sidebar_menu_items, :array, default: [
      { name: "Home", icon: "home", path: :root_path },
      { name: "Calendar", icon: "calendar", path: :calendar_schedule_path },
      { name: "Clients", icon: "clients", path: :user_profiles_path },
      { name: "Billing", icon: "billing", path: :edit_user_profile_path },
      { name: "Settings", icon: "settings", path: :edit_user_profile_path },
      { name: "Profile", icon: "User", path: :edit_user_profile_path }
    ]


    def roles
      RoleConfiguration.new.tap do |role_configuration|
        role_configuration.assign_permissions "SuperAdmin", [ "Permissions::AdminPermissionSets" ]
        role_configuration.assign_permissions "Client", [ "Permissions::ClientPermissionSets" ]
      end
    end
  end
