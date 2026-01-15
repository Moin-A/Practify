module HomePage
  class SuperAdminComponent < ApplicationComponent
    def initialize(current_user: nil)
      @current_user = current_user
    end

    def component
      
    end

    def render?
      @current_user.present?
    end
  end
end
