import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "homeIcon", "calendarIcon", "clientsIcon", "billingIcon", "settingsIcon" ]
  
  // Light emerald shade for selected icon
  activeStyles = ["bg-emerald-50", "text-emerald-700", "font-medium"]
  inactiveStyles = ["text-slate-500"]
  
  connect() {
    // Set initial active icon
    if (this.hasHomeIconTarget) {
      this.activeIcon = this.homeIconTarget
      this.activateIcon(this.activeIcon)
    }
  }

  // This function is triggered by data-action="click->home#switch" in your HTML
  switch(event) {
    event.preventDefault()
    
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
