class HomeController < ApplicationController
  def show
    authorize! :read, Slot
    @current_user = current_user
    @selected_slot_id = params[:selected_slot_id]
  end

  private
end
