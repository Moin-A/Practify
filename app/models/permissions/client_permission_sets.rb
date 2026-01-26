module Permissions
    class ClientPermissionSets < Base
      def activate!
        can :read, Calendar, user_id: user.id
        can :read, :appointment
        can :read, Slot, calendar: { user_id: user.id }
        can :create, Appointment, user_id: user.id
      end
    end
end
