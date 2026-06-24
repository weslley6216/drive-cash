import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.pendingRefresh = false
    this.handlers = {
      "turbo:submit-start":         (event) => this.onSubmitStart(event),
      "turbo:submit-end":           (event) => this.onSubmitEnd(event),
      "turbo:before-visit":         (event) => this.onBeforeVisit(event),
      "turbo:before-fetch-request": (event) => this.onBeforeFetch(event),
      "turbo:before-stream-render": (event) => this.onStreamRender(event),
      "turbo:frame-load":           (event) => this.onFrameLoad(event),
      "turbo:load":                 ()      => this.hide()
    }

    Object.entries(this.handlers).forEach(([type, handler]) => {
      document.addEventListener(type, handler)
    })
  }

  disconnect() {
    Object.entries(this.handlers).forEach(([type, handler]) => {
      document.removeEventListener(type, handler)
    })
  }

  onSubmitStart(event) {
    if (this.inPageFrame(event.target)) return
    if (this.skipsLoading(event.target)) return
    this.show()
  }

  onSubmitEnd(event) {
    if (this.inPageFrame(event.target)) return
    if (!this.pendingRefresh) this.hide()
  }

  onBeforeVisit(event) {
    if (this.isSamePath(event.detail?.url)) return
    this.show()
  }

  onBeforeFetch(event) {
    if (event.target?.id === "modal") this.show()
  }

  onStreamRender(event) {
    if (event.target?.getAttribute?.("action") === "refresh") {
      this.pendingRefresh = true
      this.show()
    }
  }

  onFrameLoad(event) {
    if (event.target?.id === "modal" && !this.pendingRefresh) this.hide()
  }

  show() {
    clearTimeout(this.safetyNet)
    this.element.classList.remove("hidden")
    this.safetyNet = setTimeout(() => this.hide(), 8000)
  }

  hide() {
    clearTimeout(this.safetyNet)
    this.pendingRefresh = false
    this.element.classList.add("hidden")
  }

  inPageFrame(element) {
    return element?.closest?.("turbo-frame")?.id === "page"
  }

  skipsLoading(element) {
    return Boolean(element?.closest?.("[data-loading-skip]"))
  }

  isSamePath(url) {
    if (!url) return false

    try {
      return new URL(url, window.location.origin).pathname === window.location.pathname
    } catch {
      return false
    }
  }
}
