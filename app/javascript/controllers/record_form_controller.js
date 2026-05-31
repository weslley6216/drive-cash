import { Controller } from '@hotwired/stimulus'

const TOGGLE_ACTIVE_EARN = ['bg-white', 'shadow-sm', 'text-emerald-700']
const TOGGLE_ACTIVE_EXPENSE = ['bg-white', 'shadow-sm', 'text-red-700']
const TOGGLE_INACTIVE = ['text-slate-500']

export default class extends Controller {
  static values = { type: String }
  static targets = [
    'typeInput', 'earningFields', 'expenseFields',
    'submit', 'tripsValue', 'tripsInput',
    'earningToggle', 'expenseToggle', 'amountTheme',
    'amountDisplay', 'amountInput'
  ]

  connect() {
    this.applyType(this.typeValue)
    this.initAmountDisplay()
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
    this.applyToggleVisual(isEarn)
    this.applyAmountTheme(isEarn)
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

  applyToggleVisual(isEarn) {
    if (!this.hasEarningToggleTarget || !this.hasExpenseToggleTarget) return
    const earn = this.earningToggleTarget
    const expense = this.expenseToggleTarget

    earn.classList.remove(...TOGGLE_ACTIVE_EARN, ...TOGGLE_INACTIVE)
    expense.classList.remove(...TOGGLE_ACTIVE_EXPENSE, ...TOGGLE_INACTIVE)

    if (isEarn) {
      earn.classList.add(...TOGGLE_ACTIVE_EARN)
      expense.classList.add(...TOGGLE_INACTIVE)
    } else {
      expense.classList.add(...TOGGLE_ACTIVE_EXPENSE)
      earn.classList.add(...TOGGLE_INACTIVE)
    }
  }

  applyAmountTheme(isEarn) {
    if (!this.hasAmountThemeTarget) return
    const el = this.amountThemeTarget
    el.classList.remove('text-red-700', 'text-emerald-700')
    el.classList.add(isEarn ? 'text-emerald-700' : 'text-red-700')
  }

  initAmountDisplay() {
    if (!this.hasAmountDisplayTarget || !this.hasAmountInputTarget) return
    const val = parseFloat(this.amountInputTarget.value || '0')
    if (val > 0) {
      const cents = Math.round(val * 100)
      this.amountDisplayTarget.value = (cents / 100).toLocaleString('pt-BR', { minimumFractionDigits: 2 })
    }
  }

  formatAmount(event) {
    const digits = event.target.value.replace(/\D/g, '')
    const cents = parseInt(digits || '0', 10)
    const value = cents / 100
    event.target.value = cents === 0 ? '' : value.toLocaleString('pt-BR', { minimumFractionDigits: 2 })
    event.target.setSelectionRange(event.target.value.length, event.target.value.length)
    if (this.hasAmountInputTarget) {
      this.amountInputTarget.value = value.toFixed(2)
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
