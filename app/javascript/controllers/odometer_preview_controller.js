import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["advance", "advanceLine", "warn"]
  static values = { currentKm: Number }

  connect() {
    this.displayInput = this.element.querySelector('[data-integer-field-target="display"]')
    if (this.displayInput) {
      this.boundRefresh = () => this.refresh()
      this.displayInput.addEventListener("input", this.boundRefresh)
    }
    this.refresh()
  }

  disconnect() {
    if (this.displayInput && this.boundRefresh) {
      this.displayInput.removeEventListener("input", this.boundRefresh)
    }
  }

  refresh() {
    if (!this.displayInput) return

    const reading = parseInt(this.displayInput.value.replace(/\D/g, ""), 10)
    const current = this.currentKmValue

    if (Number.isFinite(reading) && reading > current) {
      const delta = reading - current
      if (this.hasAdvanceLineTarget) {
        this.advanceLineTarget.textContent = `${this.format(current)} → ${this.format(reading)} km · +${this.format(delta)} km`
      }
      this.toggle(this.advanceTarget, true)
      this.toggle(this.warnTarget, false)
    } else if (Number.isFinite(reading) && reading > 0) {
      this.toggle(this.advanceTarget, false)
      this.toggle(this.warnTarget, true)
    } else {
      this.toggle(this.advanceTarget, false)
      this.toggle(this.warnTarget, false)
    }
  }

  toggle(element, visible) {
    if (!element) return
    element.classList.toggle("hidden", !visible)
  }

  format(value) {
    return value.toLocaleString("pt-BR")
  }
}
