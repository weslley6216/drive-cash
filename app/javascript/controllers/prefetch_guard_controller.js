import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.guard = (event) => {
      if (!this.element.classList.contains("hidden")) event.preventDefault()
    }
    document.addEventListener("turbo:before-prefetch", this.guard)
  }

  disconnect() {
    document.removeEventListener("turbo:before-prefetch", this.guard)
  }
}
