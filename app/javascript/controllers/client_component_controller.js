import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="client-component"
export default class extends Controller {
  selectedButton = null

  connect() {

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
