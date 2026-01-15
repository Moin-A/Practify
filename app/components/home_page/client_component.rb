module HomePage
 class ClientComponent < ApplicationComponent
  def initialize(current_user: nil)
    @current_user = current_user
  end

  def render?
    @current_user.present?
  end
 end
end
