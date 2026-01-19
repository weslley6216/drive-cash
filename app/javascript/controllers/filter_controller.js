import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["year", "month"]

  handleYearChange() {
    this.monthTarget.value = "" 
    this.submit()
  }

  submit() {
    this.element.requestSubmit()
  }
}
