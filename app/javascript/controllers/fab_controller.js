import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
    this.menuTarget.classList.toggle("flex")

    const isOpen = !this.menuTarget.classList.contains("hidden")

    if (isOpen) {
      this.buttonTarget.classList.remove("bg-blue-600", "hover:bg-blue-700", "hover:scale-105")
      this.buttonTarget.classList.add("bg-slate-700", "rotate-45")
    } else {
      this.buttonTarget.classList.remove("bg-slate-700", "rotate-45")
      this.buttonTarget.classList.add("bg-blue-600", "hover:bg-blue-700", "hover:scale-105")
    }
  }

  close(e) {
    if (!this.element.contains(e.target) && !this.menuTarget.classList.contains("hidden")) {
      this.toggle()
    }
  }
}
