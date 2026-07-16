import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["monthlyButton", "yearlyButton", "monthlyPrice", "yearlyPrice"]

  showMonthly() {
    this.select(false)
  }

  showYearly() {
    this.select(true)
  }

  select(yearly) {
    this.monthlyPriceTargets.forEach((price) => price.classList.toggle("hidden", yearly))
    this.yearlyPriceTargets.forEach((price) => price.classList.toggle("hidden", !yearly))
    this.monthlyButtonTargets.forEach((button) => this.paint(button, !yearly))
    this.yearlyButtonTargets.forEach((button) => this.paint(button, yearly))
  }

  paint(button, active) {
    button.classList.toggle("bg-white", active)
    button.classList.toggle("text-slate-900", active)
    button.classList.toggle("shadow-sm", active)
    button.classList.toggle("text-slate-500", !active)
  }
}
