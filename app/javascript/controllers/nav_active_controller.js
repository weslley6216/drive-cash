import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "part"]
  static values = { key: String }

  connect() {
    this.boundUpdate = this.update.bind(this)
    document.addEventListener("turbo:load", this.boundUpdate)
    this.update()
  }

  disconnect() {
    document.removeEventListener("turbo:load", this.boundUpdate)
  }

  update() {
    const active = document.head.querySelector(`meta[name="nav-active-${this.keyValue}"]`)?.content
    this.tabTargets.forEach((tab) => {
      this._toggle(tab, tab.dataset.navId === active)
    })
    this.partTargets.forEach((part) => {
      this._toggle(part, part.closest("[data-nav-id]")?.dataset.navId === active)
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
