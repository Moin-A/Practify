class BroadcastNotesAdded < ApplicationNotification
  def title
    "New Notes Added"
  end

  def message
    "Your therapist has added new notes from your latest session."
  end

  def note_id
    params[:note].id
  end

  def url
    user_private_client_note_path(params[:note].notable, params[:note])
  end

  def broadcast
    broadcast_to_user(user, partial: "notifications/broadcast_notes_added", locals: { notification: self })
  end
end
