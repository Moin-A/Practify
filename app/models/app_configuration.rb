  class AppConfiguration < Practify::Configuration
    preference :some_setting, :string, default: "default_value"

    preference :toggle_notification, :boolean, default: false

    # Slot credit packages shown on the booking flow.
    # Each entry should include:
    # - key: internal identifier stored in SlotCredit#package
    # - name: label shown in UI
    # - sessions: number of sessions granted (SlotCredit#slot_remaining)
    # - amount: total amount in INR (stored in SlotCredit#amount)
    # Optional:
    # - popular: boolean (adds a "Popular" badge)
    # - theme: "emerald" | "violet" | "slate" (controls accent styling)
    preference :slot_credit_packages, :array, default: [
      {
        key: "starter",
        name: "Starter",
        sessions: 1,
        amount: 1,
        popular: false,
        theme: "emerald",
        description: "Book a single session now.<br>You can always buy more later!"
      },
      {
        key: "standard",
        name: "Standard",
        sessions: 3,
        amount: 1,
        popular: true,
        theme: "emerald",
        savings_label: "Save 11%"
      },
      {
        key: "bundle",
        name: "Bundle",
        sessions: 5,
        amount: 5,
        popular: false,
        theme: "violet",
        savings_label: "Save 20%"
      }
    ]

    preference :sidebar_menu_items, :array, default: [
      { name: "Home", icon: "home", path: :root_path },
      { name: "Calendar", icon: "calendar", path: :calendar_schedule_path },
      { name: "Billing", icon: "billing", path: :invoices_path },
      { name: "Settings", icon: "settings", path: :edit_user_profile_path },
      { name: "Profile", icon: "User", path: :edit_user_profile_path }
    ]

    preference :super_admin_sidebar_menu_items, :array, default: [
      { name: "Home", icon: "home", path: :root_path },
      { name: "Calendar", icon: "calendar", path: :calendar_schedule_path },
      { name: "Clients", icon: "clients", path: :user_profiles_path },
      { name: "Billing", icon: "billing", path: :invoices_path },
      { name: "Settings", icon: "settings", path: :edit_user_profile_path },
      { name: "Profile", icon: "User", path: :edit_user_profile_path }
    ]
    preference :order_mutex_max_age, :integer, default: 5.minute


    def roles
      RoleConfiguration.new.tap do |role_configuration|
        role_configuration.assign_permissions "SuperAdmin", [ "Permissions::AdminPermissionSets" ]
        role_configuration.assign_permissions "Client", [ "Permissions::ClientPermissionSets" ]
        role_configuration.assign_permissions "therapist", [ "Permissions::TherapistPermissionSets" ]
      end
    end
  end
