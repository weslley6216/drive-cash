import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay"]

  open(event) {
    if (event) event.preventDefault()
    this.overlayTarget.classList.remove("hidden")
  }

  dismiss(event) {
    if (event) event.preventDefault()
    this.overlayTarget.classList.add("hidden")
  }
}
