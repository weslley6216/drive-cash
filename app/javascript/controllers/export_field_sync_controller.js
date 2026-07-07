import { Controller } from "@hotwired/stimulus"
import { loadExportPreview } from "utils/export_preview"

export default class extends Controller {
  static targets = ["field"]

  sync(event) {
    const { name } = event.target

    this.fieldTargets.forEach((field) => {
      if (field === event.target || field.name !== name) return

      if (field.type === "checkbox") {
        field.checked = event.target.checked
      } else {
        field.value = event.target.value
      }
    })

    loadExportPreview(this.element)
  }
}
