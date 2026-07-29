import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["download", "hint"]
  static values = { exportId: Number, timeout: Number }

  connect() {
    this.onSettled = (event) => this.settled(event)
    document.addEventListener("export:settled", this.onSettled)
    this.hold()
    this.timer = setTimeout(() => this.giveUp(), this.timeoutValue)
  }

  disconnect() {
    document.removeEventListener("export:settled", this.onSettled)
    clearTimeout(this.timer)
    this.release()
  }

  settled(event) {
    if (event.detail.exportId !== this.exportIdValue) return

    clearTimeout(this.timer)
    this.release()
    this.hintTarget.classList.add("hidden")
    if (event.detail.status === "done") this.downloadTarget.click()
  }

  giveUp() {
    this.release()
    this.hintTarget.classList.remove("hidden")
    this.element.scrollIntoView({ behavior: "smooth", block: "center" })
  }

  hold() {
    document.dispatchEvent(new CustomEvent("loading:hold"))
  }

  release() {
    document.dispatchEvent(new CustomEvent("loading:release"))
  }
}
