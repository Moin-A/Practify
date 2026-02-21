import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

// Connects to data-controller="client-component"
export default class extends Controller {
  selectedButton = null
  static values = { notificationId: Number, noteId: Number, currentUserId: Number };

  connect() { }

  mark_as_read(event) {
    const id = event.currentTarget.dataset.clientComponentNotificationIdValue;
    const note_id = event.currentTarget.dataset.clientComponentNoteIdValue
    const currentUserId = event.currentTarget.dataset.clientComponentCurrentUserIdValue

    post(`/users/${currentUserId}/private_client_notes/${note_id}/mark_as_read`, {
      body: JSON.stringify({
        notification_id: id
      }),
      responseKind: "json"
    })

  }

  selectSlot(event) {
    const button = event.currentTarget


    // Remove selected class from previous button
    if (this.selectedButton) {
      this.selectedButton.classList.remove("slot-selected")
    }

    // Add selected class to clicked button
    button.classList.add("slot-selected")
    this.selectedButton = button

  }
}
