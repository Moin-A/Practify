class ClientResourcesController < NotesController
  def index
    @notes = @notable.shared_resources
    @client_resources = @notes
  end

  def new
    @note = @notable.shared_resources.new
    @client_resource = @note
    authorize! :new, @note
  end

  def edit
    @client_resource = @note
    render turbo_stream: turbo_stream.replace(
      "modal",
      partial: "client_resources/form",
      locals: {
        client_resource: @client_resource,
        notable: @notable,
        show_cancel: true
      }
    )
  end

  def create
    @note = @notable.shared_resources.new(note_params)
    @note.category = @category
    authorize! :create, @note

    respond_to do |format|
      if @note.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Resource was successfully created!", type: :notice }),
            turbo_stream.prepend("shared_resources_list", partial: "client_resources/client_resource", locals: { client_resource: @note }),
            turbo_stream.replace("new_resource_form", partial: "client_resources/form", locals: { client_resource: @notable.shared_resources.new, notable: @notable, category: @category, frame_id: "new_resource_form", show_cancel: false })
          ]
        end
        format.html { redirect_to user_shared_resources_path(@notable), notice: "Resource was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @note.update(note_params)
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Resource was successfully updated!", type: :notice }),
            turbo_stream.replace(dom_id(@note), partial: "client_resources/client_resource", locals: { client_resource: @note })
          ]
        end
        format.html { redirect_to user_shared_resources_path(@notable), notice: "Resource was successfully updated." }
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
          turbo_stream.remove(dom_id(@note)),
          turbo_stream.update("flash_messages", partial: "shared/alert", locals: { message: "Resource was successfully destroyed!", type: :notice })
        ]
      end
      format.html { redirect_to user_shared_resources_path(@notable), notice: "Resource was successfully destroyed." }
    end
  end

  private

  def set_category
    @category = "resource"
    @category_association = :shared_resources
  end

  def client_resource_params
    params.require(:client_resource).permit(:body, :content)
    # Action Text handles :content automatically — no special permit needed beyond this
  end

  def note_params
    params.require(:client_resource).permit(:body, :content)
  end
end
