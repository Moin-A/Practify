module Permissions
  class AdminPermissionSets < Base
    def activate!
      can :manage, :all
    end
  end
end
