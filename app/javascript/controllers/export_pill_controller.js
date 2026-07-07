import { Controller } from "@hotwired/stimulus"
import { loadExportPreview } from "utils/export_preview"

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
      const badge = pill.querySelector("[data-export-pill-target='badge']")
      if (badge) {
        badge.classList.toggle("bg-blue-600", isSelected)
        badge.classList.toggle("text-white", isSelected)
        badge.classList.toggle("bg-slate-100", !isSelected)
        badge.classList.toggle("text-slate-500", !isSelected)
      }
    })
    this.radioTargets.forEach((radio) => {
      radio.checked = radio.value === value
    })
    loadExportPreview(this.element)
  }
}
