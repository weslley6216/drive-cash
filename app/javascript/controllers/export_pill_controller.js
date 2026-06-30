import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["pill", "radio"]

  select(event) {
    const value = event.currentTarget.dataset.exportPillValue
    this.pillTargets.forEach((pill) => {
      const isSelected = pill.dataset.exportPillValue === value
      pill.classList.toggle("border-blue-500", isSelected)
      pill.classList.toggle("bg-blue-50", isSelected)
      pill.classList.toggle("ring-2", isSelected)
      pill.classList.toggle("ring-blue-500/30", isSelected)
      pill.classList.toggle("border-slate-200", !isSelected)
      pill.classList.toggle("bg-white", !isSelected)
      const check = pill.querySelector("[data-export-pill-target='check']")
      if (check) check.classList.toggle("hidden", !isSelected)
    })
    this.radioTargets.forEach((radio) => {
      radio.checked = radio.value === value
    })
    this.previewFrame()
  }

  previewFrame() {
    const form = this.element.closest('form')
    if (!form) return
    const body = new URLSearchParams(new FormData(form))
    const frame = document.querySelector('[id="export-summary"]')
    if (frame) {
      frame.src = `/exports/preview?${body}`
    }
  }
}
