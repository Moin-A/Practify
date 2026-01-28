import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "homeIcon", "calendarIcon", "clientsIcon", "billingIcon", "settingsIcon" ]
  
  // Light emerald shade for selected icon
  activeStyles = ["bg-emerald-50", "text-emerald-700", "font-medium"]
  inactiveStyles = ["text-slate-500"]
  selectedSlot = ""
  
  connect() {
    // Set initial active icon
    if (this.hasHomeIconTarget) {
      this.activeIcon = this.homeIconTarget
      this.activateIcon(this.activeIcon)
    }
  }

  // This function is triggered by data-action="click->home#switch" in your HTML
  switch(event) { 
    // Get the clicked link element (not the SVG or text inside)
    const clickedIcon = event.currentTarget
    
    // Don't do anything if clicking the already active icon
    if (clickedIcon === this.activeIcon) {
      return
    }
    
    // Remove active styles from previous icon
    if (this.activeIcon) {
      this.deactivateIcon(this.activeIcon)
    }
    
    // Add active styles to clicked icon
    this.activateIcon(clickedIcon)
    this.activeIcon = clickedIcon
  }

  selectSlot(event) {
    try {
      const slotId = event.currentTarget.dataset.slotId
      this.selectedSlot = slotId
      console.log("Selected slot:", slotId)
    } catch (error) {
      console.error("Error in selectSlot:", error)
      throw error
    }
  }

  activateIcon(element) {
    // Remove inactive styles
    element.classList.remove(...this.inactiveStyles)
    // Add active styles
    element.classList.add(...this.activeStyles)
  }

  deactivateIcon(element) {
    // Remove active styles
    element.classList.remove(...this.activeStyles)
    // Add back inactive styles
    element.classList.add(...this.inactiveStyles)
  }
}
