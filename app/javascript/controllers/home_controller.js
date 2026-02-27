import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["navLink", "notificationMenu", "modal"]

  activeStyles = ["bg-emerald-50", "text-emerald-700", "font-medium"]
  inactiveStyles = ["text-slate-500"]

  connect() {
    this.highlightActiveLink()
    this._turboLoadHandler = () => this.highlightActiveLink()
    document.addEventListener("turbo:load", this._turboLoadHandler)
  }

  disconnect() {
    document.removeEventListener("turbo:load", this._turboLoadHandler)
  }

  // Purely for the sidebar/nav navigation logic
  highlightActiveLink() {
    const currentPath = window.location.pathname
    this.navLinkTargets.forEach(link => {
      const isActive = link.pathname === currentPath
      isActive ? this.activateIcon(link) : this.deactivateIcon(link)
      if (isActive) this.activeIcon = link
    })
  }

  // If you want to force show the menu via JS
  peekNotifications() {
    this.notificationMenuTarget.classList.remove('invisible', 'opacity-0')
  }

  activateIcon(element) {
    element.classList.remove(...this.inactiveStyles)
    element.classList.add(...this.activeStyles)
  }

  deactivateIcon(element) {
    element.classList.remove(...this.activeStyles)
    element.classList.add(...this.inactiveStyles)
  }
  toggleModal() {
    this.modalTarget.classList.toggle('hidden')
  }

  // --- Reschedule Calendar Logic ---

  selectTimeSlot(event) {
    const selectedTime = event.currentTarget.dataset.homeTimeParam
    const hiddenInput = document.getElementById("reschedule_selected_time")

    // 1. Persist the state in the hidden input
    if (hiddenInput) {
      hiddenInput.value = selectedTime
    }

    // 2. Update visual styling
    this.updateSlotStyling(event.currentTarget)
  }

  updateSlotStyling(selectedElement) {
    // Find all slot buttons in the calendar
    const allSlots = document.querySelectorAll('[data-action="click->home#selectTimeSlot"]')

    allSlots.forEach(slot => {
      if (slot === selectedElement) {
        // Active styled state
        slot.classList.remove('bg-white', 'text-slate-700', 'border-slate-200')
        slot.classList.add('bg-emerald-50', 'text-emerald-700', 'border-emerald-500', 'ring-1', 'ring-emerald-500')
      } else {
        // Default unselected state
        slot.classList.add('bg-white', 'text-slate-700', 'border-slate-200')
        slot.classList.remove('bg-emerald-50', 'text-emerald-700', 'border-emerald-500', 'ring-1', 'ring-emerald-500')
      }
    })
  }
}