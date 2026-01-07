  class AppConfiguration < Practify::Configuration
    preference :some_setting, :string, default: "default_value"


    def roles
      RoleConfiguration.new.tap do |role_configuration|
        role_configuration.assign_permissions "customer", "Permissions::AdminPermissionSets"
      end
    end
  end
