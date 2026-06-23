import { Controller } from '@hotwired/stimulus'

const TOGGLE_ACTIVE_EARN = ['bg-white', 'shadow-sm', 'text-emerald-700']
const TOGGLE_ACTIVE_EXPENSE = ['bg-white', 'shadow-sm', 'text-red-700']
const TOGGLE_INACTIVE = ['text-slate-500']

export default class extends Controller {
  static values = { type: String, activeVendor: String }
  static targets = [
    'typeInput', 'earningFields', 'expenseFields',
    'submit', 'tripsValue', 'tripsInput',
    'earningToggle', 'expenseToggle', 'amountTheme',
    'amountDisplay', 'amountInput',
    'vendorInput', 'vendorHint', 'vendorSuggest', 'vendorSuggestLabel'
  ]

  connect() {
    this.applyType(this.typeValue)
    this.initAmountDisplay()
    this.maybePrefillVendor()
    this.refreshVendorUi()
    this._onCategoryChange = (event) => {
      if (event.target.type === 'radio' && event.target.name === 'record[category]') {
        this.maybePrefillVendor()
        this.refreshVendorUi()
      }
    }
    this.element.addEventListener('change', this._onCategoryChange)
  }

  disconnect() {
    if (this._onCategoryChange) {
      this.element.removeEventListener('change', this._onCategoryChange)
    }
  }

  switch(event) {
    const next = event.target.value
    const departing = this.typeValue === 'earning' ? this.earningFieldsTarget : this.expenseFieldsTarget
    this.clearFieldset(departing)
    this.typeValue = next
    this.applyType(next)
  }

  clearFieldset(node) {
    node.querySelectorAll('input[type="text"], textarea').forEach(el => { el.value = '' })
    node.querySelectorAll('input[type="radio"]').forEach(el => { el.checked = false })
    this.refreshVendorUi()
  }

  categoryChanged() {
    this.maybePrefillVendor()
    this.refreshVendorUi()
  }

  clearVendor() {
    if (!this.hasVendorInputTarget) return

    this.vendorInputTarget.value = ''
    this.refreshVendorUi()
    this.vendorInputTarget.focus()
  }

  applyVendor() {
    if (!this.hasVendorInputTarget || !this.activeVendorValue) return

    this.vendorInputTarget.value = this.activeVendorValue
    this.refreshVendorUi()
  }

  refreshVendorUi() {
    if (!this.hasVendorInputTarget) return

    const current = this.vendorInputTarget.value.trim()
    const hasActive = this.activeVendorValue.length > 0
    const showHint = this.isFuel && hasActive && current === this.activeVendorValue
    const showSuggest = this.isFuel && hasActive && current.length === 0

    if (this.hasVendorHintTarget) {
      this.vendorHintTarget.classList.toggle('hidden', !showHint)
    }
    if (this.hasVendorSuggestTarget) {
      this.vendorSuggestTarget.classList.toggle('hidden', !showSuggest)
      if (this.hasVendorSuggestLabelTarget) {
        this.vendorSuggestLabelTarget.textContent = `Usar ${this.activeVendorValue}`
      }
    }
  }

  maybePrefillVendor() {
    if (!this.hasVendorInputTarget) return
    if (!this.isFuel) return
    if (this.activeVendorValue.length === 0) return
    if (this.vendorInputTarget.value.trim().length > 0) return

    this.vendorInputTarget.value = this.activeVendorValue
  }

  get isFuel() {
    const radios = Array.from(this.element.querySelectorAll('input[type="radio"]'))
    const checked = radios.find(radio => radio.name === 'record[category]' && radio.checked)
    return checked?.value === 'fuel'
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
    const addText = isEarn ? 'text-emerald-700' : 'text-red-700'
    const removeText = isEarn ? 'text-red-700' : 'text-emerald-700'
    const addPlaceholder = isEarn ? 'placeholder:text-emerald-700' : 'placeholder:text-red-700'
    const removePlaceholder = isEarn ? 'placeholder:text-red-700' : 'placeholder:text-emerald-700'
    if (this.hasAmountThemeTarget) {
      this.amountThemeTarget.classList.remove(removeText)
      this.amountThemeTarget.classList.add(addText)
    }
    if (this.hasAmountDisplayTarget) {
      this.amountDisplayTarget.classList.remove(removeText, removePlaceholder)
      this.amountDisplayTarget.classList.add(addText, addPlaceholder)
    }
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
