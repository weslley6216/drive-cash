import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "chip"]
  static classes = ["on", "off"]

  select(event) {
    if (!this.hasInputTarget) return

    this.inputTarget.value = event.params.vendor
    this.inputTarget.focus()
    this.sync()
  }

  sync() {
    this.chipTargets.forEach((chip) => {
      const pressed = chip.dataset.vendorChipsVendorParam === this.inputTarget.value
      chip.setAttribute("aria-pressed", String(pressed))
      chip.classList.remove(...(pressed ? this.offClasses : this.onClasses))
      chip.classList.add(...(pressed ? this.onClasses : this.offClasses))
    })
  }
}
