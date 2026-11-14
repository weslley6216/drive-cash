import { Controller } from "@hotwired/stimulus"

const REOPEN_KEY = "filter-popover:reopen"

export default class extends Controller {
  static targets = ["panel"]
  static values = { persistent: Boolean }

  connect() {
    if (!this.persistentValue) return

    try {
      if (!sessionStorage.getItem(REOPEN_KEY)) return

      sessionStorage.removeItem(REOPEN_KEY)
      this.panelTarget.classList.remove("hidden")
    } catch { }
  }

  toggle() {
    this.panelTarget.classList.toggle("hidden")
  }

  keepOpen() {
    try {
      sessionStorage.setItem(REOPEN_KEY, "true")
    } catch { }
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.panelTarget.classList.add("hidden")
    }
  }
}
