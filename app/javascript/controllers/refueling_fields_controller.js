import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["category", "extension"]

  connect() {
    this.toggle()
  }

  toggle() {
    if (!this.hasExtensionTarget) return

    const isFuel = this.categoryTarget.value === "fuel"
    this.extensionTarget.classList.toggle("hidden", !isFuel)
  }
}
