import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fields"]

  connect() {
    this.toggle()
  }

  toggle() {
    const box = this.element.querySelector('input[name="installment[repeat]"]')
    const checked = box && box.checked
    if (this.hasFieldsTarget) {
      this.fieldsTarget.classList.toggle("hidden", !checked)
    }
  }
}
