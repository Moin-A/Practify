import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["navLink", "notificationMenu"]

  activeStyles = ["bg-emerald-50", "text-emerald-700", "font-medium"]
  inactiveStyles = ["text-slate-500"]

  connect() {
    this.highlightActiveLink()
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
}