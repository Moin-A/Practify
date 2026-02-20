require "pry"
class NotesController < ApplicationController
  before_action :set_notable
  before_action :set_note, only: [ :show, :edit, :update, :destroy ]
  before_action :set_category
  load_and_authorize_resource # Authorize resource except creation actions which depend on @notable

  def index
    @notes = @notable.send(@category_association)
  end

  def show
  end

  def new
    @note = @notable.send(@category_association).new
    authorize! :new, @note
  end

  def create
    @note = @notable.send(@category_association).new(note_params)
    @note.category = @category
    authorize! :create, @note

    respond_to do |format|
      if @note.save
        Practify.bus.publish(:notes_added, note: @note) if @category == "note"
        if @note.category == "observation"

        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Note was successfully created!", type: :notice }),
            turbo_stream.prepend("therapist_observations_list", partial: "notes/observation", locals: { observation: @note }),
            turbo_stream.replace("new_observation_form", partial: "notes/form", locals: { note: @notable.send(@category_association).new, notable: @notable, category: @category, frame_id: "new_observation_form", show_cancel: false })
          ]
        end
        else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Note was successfully created!", type: :notice }),
            turbo_stream.prepend("private_client_notes_list", partial: "notes/note", locals: { note: @note }),
            turbo_stream.replace("new_note_form", partial: "notes/form", locals: { note: @notable.send(@category_association).new, notable: @notable, category: @category, frame_id: "new_note_form", show_cancel: false })
          ]
        end
        end
        format.html { redirect_to @notable, notice: "Note was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
     render turbo_stream: turbo_stream.replace(
      "new_note_form",
      partial: "notes/form",
      locals: {
        note: @note,
        notable: @notable,
        category: @category,
        frame_id: "new_note_form",
        show_cancel: true
      }
    )
  end

  def mark_as_read
    Noticed::Notification.find(params[:notification_id]).update(read_at: Time.current, seen_at: Time.current)
    render turbo_stream: turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Note was successfully marked as read!", type: :notice })
  end

  def update
    respond_to do |format|
      if @note.update(note_params)
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Note was successfully updated!", type: :notice }),
            turbo_stream.replace("private_client_notes_list", partial: "notes/note", locals: { note: @note }),
            turbo_stream.replace("new_note_form", partial: "notes/form", locals: { note: @notable.send(@category_association).new, notable: @notable, category: @category, frame_id: "new_note_form", show_cancel: false })
          ]
        end
        format.html { redirect_to @notable, notice: "Note was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @note.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("private_client_notes_list_#{@note.id}"),
          turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Note was successfully destroyed!", type: :notice })
        ]
      end
      format.html { redirect_to @notable, notice: "Note was successfully destroyed." }
    end
  end

  private

  def set_notable
    @notable = User.find(params[:user_id])
  end

  def set_note
    @note =@notable.notes.find_by_id(params[:id])
  end

  def set_category
    if request.path.include?("private_client_notes")
      @category = "note"
      @category_association = :private_client_notes
    elsif request.path.include?("therapist_observations")
      @category = "observation"
      @category_association = :therapist_observations
    else
      # Fallback or error handling
      @category = "note"
      @category_association = :notes
    end
  end

  def note_params
    params.require(:note).permit(:body)
  end
end
