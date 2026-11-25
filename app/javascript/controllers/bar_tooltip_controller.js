import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['column', 'tooltip', 'label', 'noData', 'values', 'field', 'fill', 'arrow']
  static classes = ['negative', 'positive']
  static values = {
    dimOpacity:     { type: Number, default: 0.45 },
    placement:      { type: String, default: 'above' },
    dismissOutside: Boolean
  }

  connect() {
    this.active = null
    this.pinned = false
    this.dismiss = (event) => {
      if (!this.element.contains(event.target)) this.deactivate()
    }
  }

  disconnect() {
    document.removeEventListener('pointerdown', this.dismiss)
  }

  show(event) {
    if (this.pinned) return

    this.activate(this.indexFor(event.currentTarget))
  }

  hide(event) {
    if (this.pinned) return

    if (this.indexFor(event.currentTarget) === this.active) this.deactivate()
  }

  toggle(event) {
    event.preventDefault()
    const index = this.indexFor(event.currentTarget)

    if (this.active === index && this.pinned) {
      this.deactivate()
    } else {
      this.pinned = true
      this.activate(index)
      if (this.dismissOutsideValue) document.addEventListener('pointerdown', this.dismiss)
    }
  }

  indexFor(column) {
    return Number(column.dataset.index)
  }

  activate(index) {
    const column = this.columnTargets.find((target) => this.indexFor(target) === index)
    if (!column) return

    this.active = index
    const muted = column.dataset.muted === 'true'

    this.labelTarget.textContent = column.dataset.labelText
    this.noDataTarget.classList.toggle('hidden', !muted)
    this.valuesTarget.classList.toggle('hidden', muted)

    if (!muted) {
      this.fieldTargets.forEach((field) => {
        field.textContent = column.dataset[field.dataset.field]
        this.applyTone(field, column)
      })
    }

    this.tooltipTarget.classList.remove('hidden')
    this.position(index, column)
    this.highlight(index)
  }

  applyTone(field, column) {
    if (field.dataset.signed !== 'true' || !this.hasNegativeClass) return

    const negative = column.dataset.negative === 'true'
    this.negativeClasses.forEach((cssClass) => field.classList.toggle(cssClass, negative))
    this.positiveClasses.forEach((cssClass) => field.classList.toggle(cssClass, !negative))
  }

  position(index, column) {
    if (this.placementValue === 'above-or-side') {
      this.anchor(index, column)
      return
    }

    const count = this.columnTargets.length
    const containerWidth = this.element.clientWidth
    const barCenter = ((index + 0.5) / count) * containerWidth
    const half = this.tooltipTarget.offsetWidth / 2
    const pad = 4
    const min = half + pad
    const max = containerWidth - half - pad
    const center = max > min ? Math.min(max, Math.max(min, barCenter)) : barCenter

    this.tooltipTarget.style.left = `${center}px`
    this.tooltipTarget.style.top = `${this.barTop(column)}px`
  }

  anchor(index, column) {
    const tooltip = this.tooltipTarget
    const arrow = this.arrowTarget
    const width = this.element.offsetWidth
    const tooltipWidth = tooltip.offsetWidth
    const tooltipHeight = tooltip.offsetHeight
    const centerX = column.offsetLeft + column.offsetWidth / 2
    const barTop = this.barTop(column)
    const clamp = (value, min, max) => Math.min(max, Math.max(min, value))

    let scrollable = this.element.parentElement
    while (scrollable && !/(auto|scroll)/.test(getComputedStyle(scrollable).overflowY)) {
      scrollable = scrollable.parentElement
    }
    const limit = scrollable ? scrollable.getBoundingClientRect().top : -Infinity

    arrow.style.top = ''
    arrow.style.bottom = ''
    arrow.style.left = ''
    arrow.style.right = ''

    if (this.element.getBoundingClientRect().top + barTop - 8 - tooltipHeight >= limit + 4) {
      const left = clamp(centerX - tooltipWidth / 2, 0, width - tooltipWidth)

      tooltip.style.left = `${left}px`
      tooltip.style.top = `${barTop - 8 - tooltipHeight}px`
      arrow.style.left = `${clamp(centerX - left, 10, tooltipWidth - 10)}px`
      arrow.style.bottom = '0'
      arrow.style.transform = 'translate(-50%, 50%) rotate(45deg)'
    } else {
      const toLeft = index >= 3
      const top = Math.max(-36, barTop - 14)
      const arrowOffset = clamp(barTop - top, 10, tooltipHeight - 10)

      tooltip.style.left = `${toLeft ? column.offsetLeft - 8 - tooltipWidth : column.offsetLeft + column.offsetWidth + 8}px`
      tooltip.style.top = `${top}px`

      if (toLeft) {
        arrow.style.right = '0'
        arrow.style.top = `${arrowOffset}px`
        arrow.style.transform = 'translate(50%, -50%) rotate(45deg)'
      } else {
        arrow.style.left = '0'
        arrow.style.top = `${arrowOffset}px`
        arrow.style.transform = 'translate(-50%, -50%) rotate(45deg)'
      }
    }
  }

  barTop(column) {
    const tops = this.fillsOf(column).map((fill) => fill.offsetTop)
    return tops.length ? Math.min(...tops) : 0
  }

  deactivate() {
    this.active = null
    this.pinned = false
    this.tooltipTarget.classList.add('hidden')
    this.clearHighlight()
    document.removeEventListener('pointerdown', this.dismiss)
  }

  highlight(index) {
    this.columnTargets.forEach((column) => {
      const isActive = this.indexFor(column) === index
      column.style.backgroundColor = isActive ? 'rgba(15, 23, 42, 0.05)' : ''
      this.fillsOf(column).forEach((fill) => {
        fill.style.opacity = isActive ? '1' : String(this.dimOpacityValue)
      })
    })
  }

  clearHighlight() {
    this.columnTargets.forEach((column) => {
      column.style.backgroundColor = ''
      this.fillsOf(column).forEach((fill) => {
        fill.style.opacity = ''
      })
    })
  }

  fillsOf(column) {
    return this.fillTargets.filter((fill) => column.contains(fill))
  }
}
