import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["category", "extension", "vendorInput", "vendorHint", "vendorSuggest", "vendorSuggestLabel"]
  static values = { activeVendor: String }

  connect() {
    this.toggleExtension()
    this.maybePrefillVendor()
    this.refreshVendorUi()
  }

  toggle() {
    this.toggleExtension()
    this.maybePrefillVendor()
    this.refreshVendorUi()
  }

  clearVendor() {
    if (!this.hasVendorInputTarget) return

    this.vendorInputTarget.value = ""
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
      this.vendorHintTarget.classList.toggle("hidden", !showHint)
    }
    if (this.hasVendorSuggestTarget) {
      this.vendorSuggestTarget.classList.toggle("hidden", !showSuggest)
      if (this.hasVendorSuggestLabelTarget) {
        this.vendorSuggestLabelTarget.textContent = `Usar ${this.activeVendorValue}`
      }
    }
  }

  toggleExtension() {
    if (this.hasExtensionTarget) {
      this.extensionTarget.classList.toggle("hidden", !this.isFuel)
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
    return this.hasCategoryTarget && this.categoryTarget.value === "fuel"
  }
}
