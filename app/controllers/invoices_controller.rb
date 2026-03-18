class InvoicesController < ApplicationController
  def index
    @invoices = SlotCredit
      .joins(slot: :appointment)
      .where(appointments: { user_id: current_user.id })
      .includes(slot: :appointment)
      .order(created_at: :desc)
  end
end
