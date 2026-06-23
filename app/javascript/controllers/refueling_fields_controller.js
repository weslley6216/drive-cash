import { Controller } from "@hotwired/stimulus"
import { normalizeVendor } from "utils/normalize_vendor"

export default class extends Controller {
  static targets = ["category", "extension", "vendorInput", "vendorHint", "vendorSuggest", "vendorSuggestLabel"]
  static values = { activeVendor: String }

  connect() {
    this.toggleExtension()
    this.refreshVendorUi()
  }

  toggle() {
    this.toggleExtension()
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

    this.vendorInputTarget.value = normalizeVendor(this.activeVendorValue)
    this.refreshVendorUi()
  }

  refreshVendorUi() {
    if (!this.hasVendorInputTarget) return

    const current = normalizeVendor(this.vendorInputTarget.value)
    const active = normalizeVendor(this.activeVendorValue)
    const hasActive = active.length > 0
    const showHint = this.isFuel && hasActive && current === active
    const showSuggest = this.isFuel && hasActive && current.length === 0

    if (this.hasVendorHintTarget) {
      this.vendorHintTarget.classList.toggle("hidden", !showHint)
    }
    if (this.hasVendorSuggestTarget) {
      this.vendorSuggestTarget.classList.toggle("hidden", !showSuggest)
      if (this.hasVendorSuggestLabelTarget) {
        this.vendorSuggestLabelTarget.textContent = `Usar ${active}`
      }
    }
  }

  toggleExtension() {
    if (this.hasExtensionTarget) {
      this.extensionTarget.classList.toggle("hidden", !this.isFuel)
    }
  }

  get isFuel() {
    return this.hasCategoryTarget && this.categoryTarget.value === "fuel"
  }
}
