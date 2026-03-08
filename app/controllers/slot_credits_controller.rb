class SlotCreditsController < ApplicationController
  before_action :set_slot_credit, only: %i[ show edit update destroy ]
  before_action :set_slot
  before_action :set_calendar

  # GET /slot_credits or /slot_credits.json
  def index
    @slot_credits = @slot.slot_credit ? [ @slot.slot_credit ] : SlotCredit.all
  end

  # GET /slot_credits/1 or /slot_credits/1.json
  def show
  end

  # GET /slot_credits/new
  def new
    @slot_credit = SlotCredit.new
  end

  # GET /slot_credits/1/edit
  def edit
  end

  # POST /slot_credits or /slot_credits.json
  def create
   @slot_credit = SlotCredit.find_or_initialize_by(slot_id: @slot.id)
   @slot_credit.package = slot_credit_params[:package]
    respond_to do |format|
      if @slot_credit.save
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "#{@slot_credit.package.titleize} Package Selected", type: :notice }),
            turbo_stream.replace("slot_credit_package", partial: "slot_credits/packages", locals: { slot: @slot.reload, calendar: @calendar })
          ]
        }
        format.html { redirect_to calendar_slot_credit_url(@calendar, @slot, @slot_credit), notice: "Slot credit was successfully created." }
        format.json { render :show, status: :created, location: @slot_credit }
      else
        format.turbo_stream { render turbo_stream: [ turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: @slot_credit.errors.full_messages.join(", "), type: :alert }) ], status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @slot_credit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /slot_credits/1 or /slot_credits/1.json
  def update
    respond_to do |format|
      if @slot_credit.update(slot_credit_params)
        format.html { redirect_to calendar_slot_credit_url(@calendar, @slot, @slot_credit), notice: "Slot credit was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @slot_credit }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @slot_credit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /slot_credits/1 or /slot_credits/1.json
  def destroy
    @slot_credit.destroy!

    respond_to do |format|
      format.html { redirect_to calendar_slot_credits_url(@calendar, @slot), notice: "Slot credit was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_slot_credit
      @slot_credit = SlotCredit.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def slot_credit_params
      params.expect(slot_credit: [ :package ])
    end

    def set_slot
      @slot = Slot.find(params[:slot_id])
    end

    def set_calendar
      @calendar = Calendar.find(params[:calendar_id])
    end
end
