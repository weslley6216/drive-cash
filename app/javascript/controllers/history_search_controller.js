import { Controller } from "@hotwired/stimulus"

let pendingFocus = null

export default class extends Controller {
  static values = { wait: { type: Number, default: 500 } }

  connect() {
    this.timeout = null

    if (pendingFocus) {
      const input = this.element.querySelector(`input[name="${pendingFocus.name}"]`)

      if (input) {
        input.focus()
        input.setSelectionRange(pendingFocus.start, pendingFocus.end)
      }

      pendingFocus = null
    }
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  debounce() {
    if (this.timeout) clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      const input = this.element.querySelector('input[name="q"]')

      if (input === document.activeElement) {
        pendingFocus = { name: input.name, start: input.selectionStart, end: input.selectionEnd }
      }

      this.element.requestSubmit()
    }, this.waitValue)
  }
}
