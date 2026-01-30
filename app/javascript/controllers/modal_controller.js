import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  close(e) {
    if (e) e.preventDefault()
    
    const frame = document.getElementById("modal")
    frame.innerHTML = ""
    frame.removeAttribute("src")
  }

  handleBackgroundClick(e) {
    if (e.target === this.element) {
      this.close()
    }
  }
}
