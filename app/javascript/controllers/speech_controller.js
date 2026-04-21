import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "mic"]

  connect() {
    this.listening = false
    const SR = window.SpeechRecognition || window.webkitSpeechRecognition
    if (!SR) {
      this.micTarget.classList.add("hidden")
      return
    }

    this.recognition = new SR()
    this.recognition.lang = "pt-BR"
    this.recognition.continuous = false
    this.recognition.interimResults = false

    this.recognition.onresult = (e) => {
      this.inputTarget.value = e.results[0][0].transcript
      this.stopListening()
      this.inputTarget.form.requestSubmit()
    }

    this.recognition.onend = () => this.stopListening()
    this.recognition.onerror = () => this.stopListening()
  }

  toggle() {
    if (!this.recognition) return
    this.listening ? this.stopListening() : this.startListening()
  }

  startListening() {
    this.listening = true
    this.micTarget.classList.add("text-violet-600", "animate-pulse")
    this.micTarget.classList.remove("text-slate-400")
    this.recognition.start()
  }

  stopListening() {
    this.listening = false
    this.micTarget.classList.remove("text-violet-600", "animate-pulse")
    this.micTarget.classList.add("text-slate-400")
    try { this.recognition?.stop() } catch (_) {}
  }
}
