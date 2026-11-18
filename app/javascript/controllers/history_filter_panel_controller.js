import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "panel", "sheet", "backdrop", "form", "submit", "clear", "hint", "unpaidRow",
    "vendorBlock", "vendorHeading", "vendorSearch", "groupSub", "groupBadge", "columnTitle", "columnEmpty"
  ]

  connect() {
    this.facets = JSON.parse(this.formTarget.dataset.facets || "[]")
    this.labels = JSON.parse(this.formTarget.dataset.labels || "{}")
    this.sync()
  }

  open(event) {
    this.panelTarget.classList.remove("hidden")
    this.sync()

    const level = event.params && event.params.level
    if (!level) return

    const group = this.element.querySelector(`[data-level="${level}"]`)
    if (group) group.scrollIntoView({ block: "nearest" })
  }

  close() {
    this.formTarget.reset()
    this.sync()
    this.panelTarget.classList.add("hidden")
  }

  clear() {
    this.allCheckboxes().forEach((checkbox) => { checkbox.checked = false })
    this.sync()
  }

  filterVendors(event) {
    const term = event.target.value.trim().toLowerCase()

    this.vendorBlockTargets.forEach((block) => {
      block.querySelectorAll("label").forEach((row) => {
        row.classList.toggle("hidden", !row.textContent.toLowerCase().includes(term))
      })
    })
  }

  toggleGroup(event) {
    const body = event.currentTarget.nextElementSibling
    if (body) body.classList.toggle("hidden")
  }

  sync() {
    const types = this.checkedValues("types[]")
    const categories = this.checkedValues("categories[]")
    const platforms = this.checkedValues("platforms[]")
    const unpaid = this.isChecked("unpaid")
    const vendorsByCategory = this.checkedVendorsByCategory()

    const includeEarnings = types.length === 0 || types.includes("earnings")
    const includeExpenses = types.length === 0 || types.includes("expenses")

    this.applyCascade(types, categories)
    this.applyVisibility(includeEarnings, includeExpenses, categories)
    this.applyVendorSearchVisibility()
    this.applyBadges(categories, platforms, vendorsByCategory)
    this.applyFooter(includeEarnings, includeExpenses, categories, platforms, unpaid, vendorsByCategory)
  }

  applyCascade(types, categories) {
    if (types.length > 0 && !types.includes("expenses")) {
      this.setChecked("unpaid", false)
      this.checkboxesNamed("categories[]").forEach((checkbox) => { checkbox.checked = false })
      this.vendorBlockTargets.forEach((block) => {
        block.querySelectorAll('input[type="checkbox"]').forEach((checkbox) => { checkbox.checked = false })
      })
    }

    if (types.length > 0 && !types.includes("earnings")) {
      this.checkboxesNamed("platforms[]").forEach((checkbox) => { checkbox.checked = false })
    }

    this.vendorBlockTargets.forEach((block) => {
      if (!categories.includes(block.dataset.category)) {
        block.querySelectorAll('input[type="checkbox"]').forEach((checkbox) => { checkbox.checked = false })
      }
    })
  }

  applyVisibility(includeEarnings, includeExpenses, categories) {
    const nothingMarked = this.typesMarked().length === 0

    this.toggleHidden(this.hintTarget, !nothingMarked)
    this.toggleHidden(this.unpaidRowTarget, !(includeExpenses && !nothingMarked))
    this.toggleLevel("platforms", !(includeEarnings && !nothingMarked))
    this.toggleLevel("categories", !(includeExpenses && !nothingMarked))
    this.toggleLevel("vendors", categories.length === 0)

    this.vendorBlockTargets.forEach((block) => {
      this.toggleHidden(block, !categories.includes(block.dataset.category))
    })

    this.vendorHeadingTargets.forEach((heading) => {
      this.toggleHidden(heading, categories.length <= 1)
    })

    if (this.hasColumnTitleTarget) {
      this.columnTitleTarget.textContent = this.columnTitleFor(includeEarnings, includeExpenses, nothingMarked)
    }
  }

  columnTitleFor(includeEarnings, includeExpenses, nothingMarked) {
    if (!nothingMarked && includeEarnings && !includeExpenses) return this.labels.platforms
    if (!nothingMarked && includeExpenses && !includeEarnings) return this.labels.categories

    return this.labels.platforms_and_categories
  }

  applyVendorSearchVisibility() {
    const visibleRows = this.vendorBlockTargets
      .filter((block) => !block.classList.contains("hidden"))
      .flatMap((block) => Array.from(block.querySelectorAll("label")))

    this.toggleHidden(this.vendorSearchTarget, visibleRows.length <= 6)
  }

  applyBadges(categories, platforms, vendorsByCategory) {
    const vendorCount = Object.values(vendorsByCategory).reduce((sum, vendors) => sum + vendors.length, 0)

    this.updateBadge("platforms", platforms.length)
    this.updateBadge("categories", categories.length)
    this.updateBadge("vendors", vendorCount)
  }

  updateBadge(group, count) {
    this.groupBadgeTargets.forEach((badge) => {
      if (badge.dataset.group !== group) return

      badge.textContent = count
      badge.classList.toggle("hidden", count === 0)
      badge.classList.toggle("flex", count > 0)
    })
  }

  applyFooter(includeEarnings, includeExpenses, categories, platforms, unpaid, vendorsByCategory) {
    const vendorCount = Object.values(vendorsByCategory).reduce((sum, vendors) => sum + vendors.length, 0)
    const nothingMarked = this.typesMarked().length === 0 && categories.length === 0 && platforms.length === 0 && vendorCount === 0
    const count = this.computeCount(includeEarnings, includeExpenses, categories, platforms, unpaid, vendorsByCategory)

    this.clearTarget.disabled = nothingMarked
    this.submitTarget.disabled = count === 0

    if (nothingMarked) {
      this.submitTarget.textContent = this.labels.all
    } else if (count === 0) {
      this.submitTarget.textContent = this.labels.none
    } else if (count === 1) {
      this.submitTarget.textContent = this.formatLabel(this.labels.one, count)
    } else {
      this.submitTarget.textContent = this.formatLabel(this.labels.other, count)
    }
  }

  formatLabel(template, count) {
    return template.replace("%{count}", count)
  }

  computeCount(includeEarnings, includeExpenses, categories, platforms, unpaid, vendorsByCategory) {
    return this.facets.reduce((total, row) => {
      if (row.type === "earnings") {
        if (!includeEarnings) return total
        if (platforms.length > 0 && !platforms.includes(row.platform)) return total

        return total + row.count
      }

      if (!includeExpenses) return total
      if (unpaid && row.paid) return total
      if (categories.length > 0 && !categories.includes(row.category)) return total

      const markedVendors = vendorsByCategory[row.category] || []
      if (markedVendors.length > 0 && !markedVendors.includes(row.vendor)) return total

      return total + row.count
    }, 0)
  }

  typesMarked() {
    return this.checkedValues("types[]")
  }

  checkedValues(name) {
    return Array.from(this.formTarget.querySelectorAll(`input[name="${name}"]:checked`)).map((input) => input.value)
  }

  isChecked(name) {
    const input = this.formTarget.querySelector(`input[name="${name}"]`)
    return !!(input && input.checked)
  }

  setChecked(name, value) {
    const input = this.formTarget.querySelector(`input[name="${name}"]`)
    if (input) input.checked = value
  }

  checkboxesNamed(prefix) {
    return Array.from(this.formTarget.querySelectorAll('input[type="checkbox"]')).filter((input) => input.name.startsWith(prefix))
  }

  checkedVendorsByCategory() {
    const result = {}

    this.vendorBlockTargets.forEach((block) => {
      result[block.dataset.category] = Array.from(block.querySelectorAll('input[type="checkbox"]:checked')).map((input) => input.value)
    })

    return result
  }

  allCheckboxes() {
    return Array.from(this.formTarget.querySelectorAll('input[type="checkbox"]'))
  }

  toggleHidden(element, hidden) {
    element.classList.toggle("hidden", hidden)
  }

  toggleLevel(level, hidden) {
    const element = this.element.querySelector(`[data-level="${level}"]`)
    if (element) this.toggleHidden(element, hidden)
  }
}
