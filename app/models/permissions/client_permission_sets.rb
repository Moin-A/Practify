module Permissions
    class ClientPermissionSets < Base
      def activate!
        can :create, Calendar, user_id: user.id
        can :read, Calendar, user_id: user.id
        can :manage, UserProfile, user_id: user.id
        can [ :read, :create, :update ], Appointment, user_id: user.id
        can [ :has_joined, :reshedule, :reset_modal, :require_payment ], Appointment do |appointment|
          appointment.publisher_id == user.id || appointment.subscriber_id == user.id
        end
        can :read, Slot, calendar: { user_id: user.id }
        can [ :read ], Note, notable_type: "User", notable_id: user.id
        can :confirm, Slot
        can :mark_as_read, Note, notable_type: "User", notable_id: user.id
      end
    end
end
