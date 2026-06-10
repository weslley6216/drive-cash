import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "icon"]

  connect() {
    this.boundUpdate = this.update.bind(this)
    document.addEventListener("turbo:load", this.boundUpdate)
    this.update()
  }

  disconnect() {
    document.removeEventListener("turbo:load", this.boundUpdate)
  }

  update() {
    const currentPath = window.location.pathname
    this.tabTargets.forEach((tab) => {
      const tabPath = new URL(tab.href, window.location.origin).pathname
      this._toggle(tab, tabPath === currentPath)
    })
    this.iconTargets.forEach((icon) => {
      const tabPath = new URL(icon.closest("a").href, window.location.origin).pathname
      this._toggle(icon, tabPath === currentPath)
    })
  }

  _toggle(element, isActive) {
    const activeClasses = this._split(element.dataset.activeClasses)
    const inactiveClasses = this._split(element.dataset.inactiveClasses)
    if (isActive) {
      element.classList.remove(...inactiveClasses)
      element.classList.add(...activeClasses)
    } else {
      element.classList.remove(...activeClasses)
      element.classList.add(...inactiveClasses)
    }
  }

  _split(value) {
    return (value || "").trim().split(/\s+/).filter(Boolean)
  }
}
