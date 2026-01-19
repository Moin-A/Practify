module HomePage
 class ClientComponent < ApplicationComponent
  attr_reader :current_user
  def initialize(current_user: nil)
    @current_user = current_user
  end

  def render?
    @current_user.present?
  end

  def user_profile
    current_user.user_profile
  end

  def grettings
    case Time.now.hour
    when 0..10
      "Good Morning"
    when 11..15
       "Good Afternoon"
    when 16..23
      "Good Evening"
    else
      "Good day"
    end
  end

  def title
    "#{grettings}, #{user_profile.first_name} #{user_profile.last_name}"
  end

  def avatar
    user_profile.avatar.attached? ? user_profile.avatar : "https://ui-avatars.com/api/?name=#{user_profile.first_name}+#{user_profile.last_name}"
  end
 end
end
