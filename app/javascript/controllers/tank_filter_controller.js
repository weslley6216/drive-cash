import { Controller } from "@hotwired/stimulus"

const ACTIVE_CLASSES = ["bg-white", "text-slate-900", "shadow-sm"]
const INACTIVE_CLASSES = ["text-slate-500"]

export default class extends Controller {
  static targets = ["tab", "row", "card"]

  select({ params: { kind } }) {
    this.tabTargets.forEach((tab) => {
      const selected = tab.dataset.tankFilterKindParam === kind
      tab.setAttribute("aria-selected", selected)
      tab.classList.remove(...ACTIVE_CLASSES, ...INACTIVE_CLASSES)
      tab.classList.add(...(selected ? ACTIVE_CLASSES : INACTIVE_CLASSES))
    })

    this.rowTargets.forEach((row) => {
      row.classList.toggle("hidden", kind !== "all" && row.dataset.tankFilterKind !== kind)
    })

    this.cardTargets.forEach((card) => {
      const rows = card.querySelectorAll('[data-tank-filter-target="row"]')
      const hasVisibleRow = Array.from(rows).some((row) => !row.classList.contains("hidden"))
      card.classList.toggle("hidden", !hasVisibleRow)
    })
  }
}
