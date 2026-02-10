module Permissions
  class AdminPermissionSets < Base
    def activate!
      can :manage, :all
      cannot :destroy, Slot do |slot|
        slot.appointment&.status&.in?([ "booked", "in_progress", "noshow" ])
      end
    end
  end
end
