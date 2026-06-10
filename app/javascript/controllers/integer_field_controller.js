import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['display', 'input']

  connect() {
    this.initDisplay()
  }

  initDisplay() {
    const val = parseInt(this.inputTarget.value || '0', 10)
    if (val > 0) {
      this.displayTarget.value = val.toLocaleString('pt-BR')
    }
  }

  format(event) {
    const digits = event.target.value.replace(/\D/g, '')
    const val = parseInt(digits || '0', 10)
    event.target.value = val === 0 ? '' : val.toLocaleString('pt-BR')
    event.target.setSelectionRange(event.target.value.length, event.target.value.length)
    this.inputTarget.value = val === 0 ? '' : val
  }
}
