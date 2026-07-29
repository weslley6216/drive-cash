import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["settled"]
  static values = { interval: Number, maxAttempts: { type: Number, default: 90 } }

  connect() {
    this.attempts = 0
    this.timer = setInterval(() => this.poll(), this.intervalValue)
  }

  settledTargetConnected() {
    this.stop()
    this.element.removeAttribute("src")
  }

  poll() {
    this.attempts += 1

    if (this.attempts > this.maxAttemptsValue) {
      this.stop()
      return
    }

    this.element.reload()
  }

  disconnect() {
    this.stop()
  }

  stop() {
    clearInterval(this.timer)
  }
}
