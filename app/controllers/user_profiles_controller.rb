class UserProfilesController < ApplicationController
  before_action :set_user_profile, only: [ :show, :edit, :update, :destroy ]

  def index
    @user_profile = current_user.user_profile
    redirect_to user_profile_path(@user_profile) if @user_profile
  end

  def show
  end

  def new
    @user_profile = current_user.build_user_profile
  end

  def create
    @user_profile = current_user.build_user_profile(user_profile_params)

    if @user_profile.save
      redirect_to @user_profile, notice: "User profile was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user_profile = current_user.user_profile

    # respond_to do |format|
    #   format.turbo_stream { render turbo_stream: turbo_stream.update("user_profile", partial: "user_profiles/form", locals: { user_profile: @user_profile }) }
    #   format.html { render :edit }
    # end
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "dashboard_content",
          partial: "user_profiles/form",
          locals: { user_profile: @user_profile }
        )
      end
    end
  end

  def update
    if @user_profile.update(user_profile_params)
      redirect_to @user_profile, notice: "User profile was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user_profile.destroy
    redirect_to user_profiles_url, notice: "User profile was successfully destroyed."
  end

  private

  def set_user_profile
    @user_profile = current_user.user_profile
    redirect_to new_user_profile_path, alert: "User profile not found." unless @user_profile
  end

  def user_profile_params
    params.require(:user_profile).permit(:first_name, :last_name, :profile_picture, :bio, :location, professional_info: {})
  end
end
