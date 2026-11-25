import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  select(event) {
    if (!this.hasInputTarget) return

    this.inputTarget.value = event.params.vendor
    this.inputTarget.focus()
  }
}
