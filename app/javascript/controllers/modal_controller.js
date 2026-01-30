import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    history.pushState({ modalOpen: true }, "", window.location.href)

    this.boundHandlePopstate = this.handlePopstate.bind(this)
    window.addEventListener("popstate", this.boundHandlePopstate)
  }

  disconnect() {
    window.removeEventListener("popstate", this.boundHandlePopstate)
  }

  close(e) {
    if (e) e.preventDefault()
    history.back()
  }

  handleBackgroundClick(e) {
    if (e.target === this.element) {
      this.close()
    }
  }

  handlePopstate() {
    const frame = document.getElementById("modal")
    if (frame) {
      frame.innerHTML = ""
      frame.removeAttribute("src")
    }
  }
}