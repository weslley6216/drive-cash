import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.showHandler = () => this.show()
    this.hideHandler = () => this.scheduleHide()

    document.addEventListener("turbo:submit-start", this.showHandler)
    document.addEventListener("turbo:before-visit", this.showHandler)
    document.addEventListener("turbo:submit-end", this.hideHandler)
    document.addEventListener("turbo:load", this.hideHandler)
  }

  disconnect() {
    document.removeEventListener("turbo:submit-start", this.showHandler)
    document.removeEventListener("turbo:before-visit", this.showHandler)
    document.removeEventListener("turbo:submit-end", this.hideHandler)
    document.removeEventListener("turbo:load", this.hideHandler)
  }

  show() {
    clearTimeout(this.hideTimeout)
    clearTimeout(this.safetyNet)
    this.element.classList.remove("hidden")
    this.safetyNet = setTimeout(() => this.forceHide(), 5000)
  }

  // Defer hiding so a turbo:before-visit following submit-end can cancel it
  scheduleHide() {
    this.hideTimeout = setTimeout(() => this.forceHide(), 80)
  }

  forceHide() {
    clearTimeout(this.safetyNet)
    clearTimeout(this.hideTimeout)
    this.element.classList.add("hidden")
  }
}
