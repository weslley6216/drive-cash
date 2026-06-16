import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay"]

  connect() {
    this.overlay = this.overlayTarget
    document.body.appendChild(this.overlay)

    this.onOverlayClick = (event) => {
      if (event.target.closest("[data-confirm-action-dismiss]")) {
        event.preventDefault()
        this.dismiss()
      }
    }
    this.overlay.addEventListener("click", this.onOverlayClick)
  }

  disconnect() {
    this.overlay?.removeEventListener("click", this.onOverlayClick)
    this.overlay?.remove()
  }

  open(event) {
    if (event) event.preventDefault()
    this.overlay.classList.remove("hidden")
  }

  dismiss() {
    this.overlay.classList.add("hidden")
  }
}
