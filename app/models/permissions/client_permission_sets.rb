module Permissions
    class ClientPermissionSets < Base
      def activate!
        can :create, Calendar, user_id: user.id
        can :read, Calendar, user_id: user.id
        can [ :read, :create, :update ], Appointment, user_id: user.id
        can [ :has_joined ], Appointment do |appointment|
          appointment.publisher_id == user.id || appointment.subscriber_id == user.id
        end
        can :read, Slot, calendar: { user_id: user.id }
        can :confirm, Slot
      end
    end
end
