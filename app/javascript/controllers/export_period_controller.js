import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["chip", "radio", "customFields"]

  select(event) {
    const value = event.currentTarget.dataset.exportPeriodValue
    this.chipTargets.forEach((chip) => {
      const isSelected = chip.dataset.exportPeriodValue === value
      const variant = chip.dataset.exportPeriodVariant

      if (isSelected) {
        chip.classList.add("text-white")
        if (variant === "mobile") {
          chip.classList.add("bg-slate-800")
          chip.classList.add("border-slate-800")
        } else {
          chip.classList.add("bg-blue-600")
          chip.classList.add("border-blue-600")
        }
        chip.classList.remove("bg-white", "text-slate-600", "border-slate-200")
      } else {
        chip.classList.remove("text-white")
        if (variant === "mobile") {
          chip.classList.remove("bg-slate-800", "border-slate-800")
        } else {
          chip.classList.remove("bg-blue-600", "border-blue-600")
        }
        chip.classList.add("bg-white", "text-slate-600", "border-slate-200")
      }
    })

    this.radioTargets.forEach((radio) => {
      radio.checked = radio.value === value
    })

    this.customFieldsTargets.forEach((el) => el.classList.toggle("hidden", value !== "custom"))

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
