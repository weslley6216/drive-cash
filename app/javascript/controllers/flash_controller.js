// app/javascript/controllers/flash_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 3000 } }

  connect() {
    setTimeout(() => {
      this.element.style.transition = "opacity 0.6s ease, transform 0.6s ease"
      this.element.style.opacity = "0"
      this.element.style.transform = "translateY(-20px)"

      setTimeout(() => this.element.remove(), 600)
    }, this.delayValue)
  }
}
