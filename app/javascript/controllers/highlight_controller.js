import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static classes = ["active"]

  connect() {
    const id = new URLSearchParams(location.search).get("highlight")
    if (!id) return

    const target = this.element.querySelector(`#${CSS.escape(id)}`)
    if (!target || !target.checkVisibility()) return

    target.scrollIntoView({ block: "center" })
    target.classList.add(...this.activeClasses)
    setTimeout(() => target.classList.remove(...this.activeClasses), 2000)

    const url = new URL(location.href)
    url.searchParams.delete("highlight")
    history.replaceState(history.state, "", url)
  }
}
