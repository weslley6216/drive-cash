import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['column', 'tooltip', 'arrow', 'label', 'noData', 'values', 'earnValue', 'expValue', 'fill']

  connect() {
    this.active = null
    this.pinned = false
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
      this.earnValueTarget.textContent = column.dataset.earn
      this.expValueTarget.textContent = column.dataset.exp
    }

    this.tooltipTarget.classList.remove('hidden')
    this.position(index)
    this.highlight(index)
  }

  position(index) {
    const count = this.columnTargets.length
    const containerWidth = this.element.clientWidth
    const barCenter = ((index + 0.5) / count) * containerWidth
    const half = this.tooltipTarget.offsetWidth / 2
    const pad = 4
    const min = half + pad
    const max = containerWidth - half - pad
    const center = max > min ? Math.min(max, Math.max(min, barCenter)) : barCenter

    this.tooltipTarget.style.left = `${center}px`

    if (this.hasArrowTarget) {
      const offset = Math.max(-half + 8, Math.min(half - 8, barCenter - center))
      this.arrowTarget.style.transform = `translateX(${offset}px) rotate(45deg)`
    }
  }

  deactivate() {
    this.active = null
    this.pinned = false
    this.tooltipTarget.classList.add('hidden')
    this.clearHighlight()
  }

  highlight(index) {
    this.columnTargets.forEach((column) => {
      const isActive = this.indexFor(column) === index
      column.style.backgroundColor = isActive ? 'rgba(15, 23, 42, 0.05)' : ''
      this.fillsOf(column).forEach((fill) => {
        fill.style.opacity = isActive ? '1' : '0.45'
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
