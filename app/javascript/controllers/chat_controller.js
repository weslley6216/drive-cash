import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submit", "messages", "userTemplate", "typingTemplate"]

  send(e) {
    const message = this.inputTarget.value.trim()
    if (!message || this.inputTarget.readOnly) {
      e.preventDefault()
      return
    }

    this.appendOptimisticUI(message)
    this.disableInput()
  }

  handleEnter(e) {
    if (!e.shiftKey) {
      e.preventDefault()
      e.target.form.requestSubmit()
    }
  }

  clearInput() {
    this.inputTarget.value = ""
    this.inputTarget.style.height = "auto"
    this.removeTypingIndicator()
    this.enableInput()
  }

  cancelPreview(e) {
    const actionName = e.target.dataset.actionName
    const card = e.target.closest(".flex.items-start")

    if (card) card.remove()

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    fetch('/chat/cancel', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-CSRF-Token': csrfToken,
        'Accept': 'text/vnd.turbo-stream.html'
      },
      body: new URLSearchParams({ action_name: actionName })
    }).then(res => res.text()).then(html => {
      Turbo.renderStreamMessage(html)
    })
  }

  confirmSubmission(e) {
    const container = e.target.closest("[data-chat-target='cardActions']")
  
    if (container) {
      container.querySelectorAll("button").forEach(btn => {
        btn.disabled = true
        btn.classList.add("opacity-50", "pointer-events-none")
      })
    }
  }

  appendOptimisticUI(message) {
    const userNode = this.userTemplateTarget.content.cloneNode(true)
    userNode.querySelector("[data-message-content]").textContent = message
    this.messagesTarget.appendChild(userNode)

    const typingNode = this.typingTemplateTarget.content.cloneNode(true)
    this.messagesTarget.appendChild(typingNode)
  }

  removeTypingIndicator() {
    document.getElementById("chat_typing")?.remove()
  }

  disableInput() {
    this.inputTarget.readOnly = true
    this.submitTarget.disabled = true
    this.submitTarget.classList.add("opacity-50")
  }

  enableInput() {
    this.inputTarget.readOnly = false
    this.submitTarget.disabled = false
    this.submitTarget.classList.remove("opacity-50")
    this.inputTarget.focus()
  }
}
