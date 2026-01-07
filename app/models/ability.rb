class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user = nil)
    @user = user
    activate_permissions
  end

  def activate_permissions
    Practify.config.roles.activate_permissions self
  end
end
