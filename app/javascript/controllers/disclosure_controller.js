import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "iconOpen", "iconClosed"]

  toggle() {
    const hidden = this.panelTarget.classList.toggle("hidden")
    if (this.hasIconOpenTarget && this.hasIconClosedTarget) {
      this.iconOpenTarget.classList.toggle("hidden", hidden)
      this.iconClosedTarget.classList.toggle("hidden", !hidden)
    }
  }
}
