import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { wait: { type: Number, default: 400 } }

  connect() {
    this.timeout = null
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  debounce() {
    if (this.timeout) clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.element.requestSubmit(), this.waitValue)
  }
}
