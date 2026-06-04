import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['display', 'input']

  connect() {
    this.initDisplay()
  }

  initDisplay() {
    const val = parseFloat(this.inputTarget.value || '0')
    if (val > 0) {
      const cents = Math.round(val * 100)
      this.displayTarget.value = (cents / 100).toLocaleString('pt-BR', { minimumFractionDigits: 2 })
    }
  }

  format(event) {
    const digits = event.target.value.replace(/\D/g, '')
    const cents = parseInt(digits || '0', 10)
    const value = cents / 100
    event.target.value = cents === 0 ? '' : value.toLocaleString('pt-BR', { minimumFractionDigits: 2 })
    event.target.setSelectionRange(event.target.value.length, event.target.value.length)
    this.inputTarget.value = value.toFixed(2)
  }
}
