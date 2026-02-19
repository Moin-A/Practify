module Permissions
    class TherapistPermissionSets < Base
      def activate!
        can :create, Calendar, user_id: user.id
        can :read, Calendar, user_id: user.id
        can [ :read, :create, :update ], Appointment, user_id: user.id
        can [ :read, :create, :update, :destroy ], Note, notable_type: "User"
      end
    end
end
