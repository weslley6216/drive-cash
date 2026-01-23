import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    if (this.urlValue) {
      const newUrl = new URL(this.urlValue, window.location.origin)
      window.history.replaceState({}, "", newUrl)
    }
  }
}
