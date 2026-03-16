import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "hamburgerIcon", "closeIcon"]

  connect() {
    this._outsideClickHandler = this._handleOutsideClick.bind(this)
  }

  disconnect() {
    document.removeEventListener("click", this._outsideClickHandler)
  }

  toggleMenu(event) {
    event.stopPropagation()
    this.menuTarget.classList.contains("pointer-events-none") ? this._open() : this._close()
  }

  closeMenu() {
    this._close()
  }

  _open() {
    this.menuTarget.classList.remove("opacity-0", "-translate-y-2", "pointer-events-none")
    this.menuTarget.classList.add("opacity-100", "translate-y-0")
    this.hamburgerIconTarget.classList.add("hidden")
    this.closeIconTarget.classList.remove("hidden")
    // Defer so this same click doesn't immediately trigger the outside-click handler
    setTimeout(() => document.addEventListener("click", this._outsideClickHandler), 0)
  }

  _close() {
    this.menuTarget.classList.remove("opacity-100", "translate-y-0")
    this.menuTarget.classList.add("opacity-0", "-translate-y-2", "pointer-events-none")
    this.hamburgerIconTarget.classList.remove("hidden")
    this.closeIconTarget.classList.add("hidden")
    document.removeEventListener("click", this._outsideClickHandler)
  }

  _handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this._close()
    }
  }
}
