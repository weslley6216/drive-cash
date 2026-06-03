import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "eye", "eyeOff"]

  toggle(event) {
    if (event) event.preventDefault()
    const showing = this.inputTarget.type === "text"
    this.inputTarget.type = showing ? "password" : "text"
    if (this.hasEyeTarget && this.hasEyeOffTarget) {
      this.eyeTarget.classList.toggle("hidden", !showing)
      this.eyeOffTarget.classList.toggle("hidden", showing)
    }
  }
}
