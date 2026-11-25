import { Controller } from "@hotwired/stimulus"
import VoiceWave from "utils/voice_wave"

const ERROR_NOTICES = { "not-allowed": "denied", "service-not-allowed": "denied", "aborted": null }
const DEFAULT_NOTICE = "silence"
const UNDERSTOOD_DELAY_MS = 700
const NOTICE_MS = 4000

export default class extends Controller {
  static targets = [
    "input", "mic", "voice", "backdrop", "sheet", "panel", "phaseDot", "phaseLabel",
    "hint", "transcript", "caret", "timer", "wave", "sendIcon", "checkIcon", "notice", "noticeText"
  ]

  connect() {
    this.state = "closed"
    this.sawError = false
    this.listeningLabel = this.phaseLabelTarget.textContent
    this.reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    this.wave = new VoiceWave(Array.from(this.waveTarget.querySelectorAll("span")), { reducedMotion: this.reducedMotion })

    const SpeechRecognitionClass = window.SpeechRecognition || window.webkitSpeechRecognition
    if (!SpeechRecognitionClass) {
      this.micTarget.classList.add("hidden")
      return
    }

    this.recognition = new SpeechRecognitionClass()
    this.recognition.lang = "pt-BR"
    this.recognition.continuous = false
    this.recognition.interimResults = true
    this.recognition.onspeechstart = () => this.wave.voice(true)
    this.recognition.onspeechend = () => this.wave.voice(false)
    this.recognition.onresult = (event) => this.onresult(event)
    this.recognition.onerror = (event) => this.onerror(event)
    this.recognition.onend = () => this.onend()
  }

  open() {
    if (!this.recognition) return

    this.state = "listening"
    this.sawError = false
    this.showPanel()
    this.resetPanelUI()
    this.wave.reset()
    this.wave.start()
    this.startTimer()
    this.panelTarget.focus()
    this.recognition.start()
  }

  onresult(event) {
    if (this.state !== "listening") return

    let text = ""
    let isFinal = false
    for (const result of event.results) {
      text += result[0].transcript
      if (result.isFinal) isFinal = true
    }

    this.transcriptTarget.textContent = text
    this.hintTarget.classList.add("hidden")
    this.caretTarget.classList.remove("hidden")
    this.wave.voice(true)

    if (isFinal) this.understand(text)
  }

  send() {
    if (this.state !== "listening") return

    const text = this.transcriptTarget.textContent.trim()
    if (!text) {
      this.fail(DEFAULT_NOTICE)
      return
    }

    this.stopRecognition()
    this.understand(text)
  }

  sendWithEnter(event) {
    if (this.state !== "listening") return

    event.preventDefault()
    this.send()
  }

  cancel() {
    if (this.state !== "listening") return

    this.state = "cancelled"
    this.stopRecognition()
    this.closePanel()
  }

  onerror(event) {
    this.sawError = true
    if (this.state !== "listening") return

    const kind = event.error in ERROR_NOTICES ? ERROR_NOTICES[event.error] : DEFAULT_NOTICE
    if (kind) this.fail(kind)
  }

  onend() {
    if (this.state === "listening" && !this.sawError) this.fail(DEFAULT_NOTICE)
  }

  understand(text) {
    this.state = "understood"
    this.phaseDotTarget.classList.remove("bg-violet-500", "animate-pulse")
    this.phaseDotTarget.classList.add("bg-emerald-500")
    this.phaseLabelTarget.classList.remove("text-violet-600")
    this.phaseLabelTarget.classList.add("text-emerald-600")
    this.phaseLabelTarget.textContent = this.phaseLabelTarget.dataset.understoodLabel
    this.sendIconTarget.classList.add("hidden")
    this.checkIconTarget.classList.remove("hidden")
    this.caretTarget.classList.add("hidden")
    this.inputTarget.value = text
    this.voiceTarget.value = "1"

    setTimeout(() => {
      this.closePanel()
      this.inputTarget.form.requestSubmit()
    }, UNDERSTOOD_DELAY_MS)
  }

  fail(kind) {
    this.state = "failed"
    this.closePanel()
    this.noticeTextTarget.textContent = this.noticeTarget.dataset[kind]
    this.noticeTarget.classList.remove("hidden")
    clearTimeout(this.noticeTimeout)
    this.noticeTimeout = setTimeout(() => this.noticeTarget.classList.add("hidden"), NOTICE_MS)
  }

  showPanel() {
    this.backdropTarget.classList.remove("opacity-0", "pointer-events-none")
    this.sheetTarget.classList.remove("invisible")

    if (this.reducedMotion) {
      this.sheetTarget.classList.replace("translate-y-[105%]", "translate-y-0")
    } else {
      requestAnimationFrame(() => this.sheetTarget.classList.replace("translate-y-[105%]", "translate-y-0"))
    }
  }

  closePanel() {
    this.sheetTarget.classList.replace("translate-y-0", "translate-y-[105%]")
    this.backdropTarget.classList.add("opacity-0", "pointer-events-none")
    this.wave.stop()
    this.stopTimer()

    const hide = () => this.sheetTarget.classList.add("invisible")
    if (this.reducedMotion) {
      hide()
    } else {
      this.sheetTarget.addEventListener("transitionend", hide, { once: true })
    }
  }

  resetPanelUI() {
    this.transcriptTarget.textContent = ""
    this.hintTarget.classList.remove("hidden")
    this.caretTarget.classList.add("hidden")
    this.phaseDotTarget.classList.remove("bg-emerald-500")
    this.phaseDotTarget.classList.add("bg-violet-500", "animate-pulse")
    this.phaseLabelTarget.classList.remove("text-emerald-600")
    this.phaseLabelTarget.classList.add("text-violet-600")
    this.phaseLabelTarget.textContent = this.listeningLabel
    this.sendIconTarget.classList.remove("hidden")
    this.checkIconTarget.classList.add("hidden")
    this.timerTarget.textContent = "0:00"
  }

  startTimer() {
    this.timerStart = Date.now()
    this.timerInterval = setInterval(() => this.renderTimer(), 1000)
  }

  renderTimer() {
    const elapsedSeconds = Math.floor((Date.now() - this.timerStart) / 1000)
    const minutes = Math.floor(elapsedSeconds / 60)
    const seconds = String(elapsedSeconds % 60).padStart(2, "0")
    this.timerTarget.textContent = `${minutes}:${seconds}`
  }

  stopTimer() {
    clearInterval(this.timerInterval)
  }

  stopRecognition() {
    try {
      this.recognition.abort()
    } catch (_) {}
  }
}
