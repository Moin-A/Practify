
class SessionsController < ApplicationController
  
  allow_unauthenticated_access only: %i[ new create omniauth ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def omniauth
    auth = request.env['omniauth.auth']
    
    # Find or create user by email (since email_address is unique)
    @user = User.find_or_create_by(email_address: auth['info']['email']) do |u|
      u.password = SecureRandom.hex(16) # Generate random password for OAuth users
      u.uid = auth['uid']
      u.provider = auth['provider']
    end
    
    # Update uid and provider if they exist and user was found by email
    if @user.persisted? && auth['uid']
      @user.update(uid: auth['uid'], provider: auth['provider']) if @user.uid.blank?
    end
    
    if @user.persisted? && @user.valid?
      start_new_session_for @user
      redirect_to root_path, notice: "Successfully signed in with Google!"
    else
      redirect_to new_session_path, alert: "Failed to sign in with Google. #{@user.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
