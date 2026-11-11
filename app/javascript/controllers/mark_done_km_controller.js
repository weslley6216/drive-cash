import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["error", "info", "help", "submit", "companion"]
  static values = {
    odometer: Number,
    max: Number,
    lastKm: Number,
    item: String,
    belowMessage: String,
    belowCompanionMessage: String,
    aboveMessage: String,
    advanceMessage: String
  }

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

    const reading = this.readingKm()
    const message = this.errorMessage(reading)

    if (message) {
      this.show(message)
    } else if (Number.isFinite(reading) && reading > this.odometerValue) {
      this.show(null, this.advanceMessageValue.replace("__KM__", this.format(reading)))
    } else {
      this.show(null, null)
    }
  }

  readingKm() {
    return parseInt(this.displayInput.value.replace(/\D/g, ""), 10)
  }

  errorMessage(reading) {
    if (!Number.isFinite(reading)) return null
    if (reading < this.lastKmValue) {
      return this.belowMessageValue.replace("__KM__", this.format(this.lastKmValue))
    }

    const belowCompanion = this.checkedCompanionTargets().find((companion) => reading < Number(companion.dataset.lastKm))
    if (belowCompanion) {
      return this.belowCompanionMessageValue.replace("__ITEM__", belowCompanion.dataset.item).replace("__KM__", this.format(Number(belowCompanion.dataset.lastKm)))
    }

    if (reading > this.maxValue) {
      return this.aboveMessageValue.replace("__KM__", this.format(this.maxValue))
    }

    return null
  }

  checkedCompanionTargets() {
    return this.companionTargets.filter((companion) => companion.checked)
  }

  show(errorMessage, infoMessage) {
    if (errorMessage) this.errorTarget.lastElementChild.textContent = errorMessage
    this.toggle(this.errorTarget, !!errorMessage)
    this.toggle(this.infoTarget, !errorMessage && !!infoMessage)
    if (infoMessage) this.infoTarget.lastElementChild.textContent = infoMessage
    this.toggle(this.helpTarget, !errorMessage && !infoMessage)
    this.submitTarget.disabled = !!errorMessage
  }

  toggle(element, visible) {
    element.classList.toggle("hidden", !visible)
  }

  format(value) {
    return value.toLocaleString("pt-BR")
  }
}
