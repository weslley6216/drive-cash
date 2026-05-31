import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { type: String }
  static targets = ['typeInput', 'earningFields', 'expenseFields', 'submit', 'tripsValue', 'tripsInput']

  connect() {
    this.applyType(this.typeValue)
  }

  switch(event) {
    const next = event.target.value
    this.typeValue = next
    this.applyType(next)
  }

  applyType(type) {
    const isEarn = type === 'earning'
    this.earningFieldsTarget.classList.toggle('hidden', !isEarn)
    this.expenseFieldsTarget.classList.toggle('hidden', isEarn)
    this.toggleFieldset(this.earningFieldsTarget, !isEarn)
    this.toggleFieldset(this.expenseFieldsTarget, isEarn)
    this.applyCtaTheme(isEarn)
  }

  toggleFieldset(node, disabled) {
    node.querySelectorAll('input, select, textarea, button').forEach(el => {
      if (el.dataset.recordFormTarget === 'typeInput') return
      el.disabled = disabled
    })
  }

  applyCtaTheme(isEarn) {
    if (!this.hasSubmitTarget) return
    const btn = this.submitTarget
    btn.classList.remove('bg-red-600', 'shadow-red-600/20', 'bg-emerald-600', 'shadow-emerald-600/20')
    if (isEarn) {
      btn.classList.add('bg-emerald-600', 'shadow-emerald-600/20')
    } else {
      btn.classList.add('bg-red-600', 'shadow-red-600/20')
    }
  }

  incrementTrips(event) {
    event.preventDefault()
    this.updateTrips(parseInt(this.tripsInputTarget.value, 10) + 1)
  }

  decrementTrips(event) {
    event.preventDefault()
    const next = Math.max(1, parseInt(this.tripsInputTarget.value, 10) - 1)
    this.updateTrips(next)
  }

  updateTrips(value) {
    this.tripsInputTarget.value = value
    this.tripsValueTarget.textContent = value
  }
}
