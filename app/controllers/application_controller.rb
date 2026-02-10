class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user

  rescue_from CanCan::AccessDenied do |exception|
    message = exception.message || "You are not authorized to access this page."
    render turbo_stream: [ turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: message, type: :alert }) ], status: :unprocessable_entity
  end

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
