import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["active"]

  connect() {
    if (!this.hasActiveTarget) return

    const chip = this.activeTarget.getBoundingClientRect()
    const strip = this.element.getBoundingClientRect()

    this.element.scrollLeft += (chip.left + chip.width / 2) - (strip.left + strip.width / 2)
  }
}
