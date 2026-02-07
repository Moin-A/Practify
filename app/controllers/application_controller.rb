class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user


  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  def current_user
    @current_user ||= Current.session&.user
  end

  def super_admin_user
    User.joins(:roles).where(roles: { name: "SuperAdmin" }).first
  end
end
