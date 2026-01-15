module HomePage
class HomeComponent < ApplicationComponent
  def initialize(current_user: nil)
    @current_user = current_user
  end

  def component
    if @current_user.super_admin?
      HomePage::SuperAdminComponent.new(current_user: @current_user)
    elsif @current_user.client?
      HomePage::ClientComponent.new(current_user: @current_user)
    elsif @current_user.therapist?
      HomePage::TherapistComponent.new(current_user: @current_user)
    elsif @current_user.admin?
      HomePage::AdminComponent.new(current_user: @current_user)
    else
      raise CanCan::AccessDenied.new("You are not authorized to access this page.")
    end
  end

  def render?
    @current_user.present?
  end
end
end
