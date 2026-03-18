import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["notes", "observation", "sharedResource", "dropdown", "notesContent", "observationContent", "sharedResourceContent"]
  static classes = ["hidden", "visible"]

  connect() {
    // Set initial state: notes open, others closed
    this.activeSection = "notes"

    // Apply initial CSS classes
    this.notesTarget.classList.add("section-visible")
    this.observationTarget.classList.add("section-hidden")
    if (this.hasSharedResourceTarget) {
      this.sharedResourceTarget.classList.add("section-hidden")
    }
  }

  toggle(event) {
    const requestedSection = event.params.type

    // Don't toggle if clicking already active section
    if (this.activeSection === requestedSection) return

    // Toggle sections
    if (requestedSection === "observation") {
      this.hide(this.notesTarget)
      this.show(this.observationTarget)
      this.activeSection = "observation"
    } else {
      this.hide(this.observationTarget)
      this.show(this.notesTarget)
      this.activeSection = "notes"
    }
  }

  toggleNotes(event) {
    this.openSection(this.notesContentTarget)
  }

  toggleObservation(event) {
    this.openSection(this.observationContentTarget)
  }

  toggleSharedResource(event) {
    this.openSection(this.sharedResourceContentTarget)
  }

  // Private helper
  openSection(toOpen) {
    const contents = [this.notesContentTarget, this.observationContentTarget]
    if (this.hasSharedResourceContentTarget) {
      contents.push(this.sharedResourceContentTarget)
    }

    contents.forEach(content => {
      if (content === toOpen) {
        content.style.maxHeight = "9999px"
      } else {
        content.style.maxHeight = "0px"
      }
    })
  }

  show(element) {
    element.classList.remove("section-hidden")
    element.classList.add("section-visible")
  }

  hide(element) {
    element.classList.remove("section-visible")
    element.classList.add("section-hidden")
  }

  toggleDropdown(event) {
    if (!this.hasDropdownTarget) return
    this.dropdownTarget.classList.toggle('hidden')
  }
}
