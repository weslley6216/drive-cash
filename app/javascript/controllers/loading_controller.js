import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.showHandler = () => this.show()
    this.hideHandler = () => this.hide()

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
    clearTimeout(this.safetyNet)
    this.element.classList.remove("hidden")
    this.safetyNet = setTimeout(() => this.hide(), 5000)
  }

  hide() {
    clearTimeout(this.safetyNet)
    this.element.classList.add("hidden")
  }
}
