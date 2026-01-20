import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "result"]

  calculate() {
    let total = 0
    
    this.inputTargets.forEach((element) => {
      const value = parseFloat(element.value) || 0
      if (element.dataset.type === "earning") {
        total += value
      } else {
        total -= value
      }
    })

    this.resultTarget.textContent = `R$ ${total.toFixed(2).replace('.', ',')}`
    
    this.resultTarget.classList.toggle("text-red-600", total < 0)
    this.resultTarget.classList.toggle("text-blue-700", total >= 0)
  }

  clearIfZero(e) {
    if (parseFloat(e.target.value) === 0) {
      e.target.value = ""
    }
  }
  
  resetIfEmpty(e) {
    if (e.target.value === "") {
      e.target.value = "0.00"
      this.calculate()
    }
  }
}
