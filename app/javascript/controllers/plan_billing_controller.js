import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["monthlyButton", "yearlyButton", "monthlyPrice", "yearlyPrice"]
  static classes = ["active", "idle"]

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
    button.classList.remove(...(active ? this.idleClasses : this.activeClasses))
    button.classList.add(...(active ? this.activeClasses : this.idleClasses))
  }
}
