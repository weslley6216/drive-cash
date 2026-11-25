const LEVEL_SILENT = 0.06
const LEVEL_VOICE_THRESHOLD = 0.12
const TICK_MS = 110

function staticSpeakingPattern(barCount) {
  return Array.from({ length: barCount }, (_, index) => {
    if (index < 18) return LEVEL_SILENT
    const t = (index - 18) / 3.2
    return 0.18 + (0.8 * Math.abs(Math.sin(t * 2.1)) * (0.6 + (0.4 * Math.sin(t * 0.9))))
  })
}

export default class VoiceWave {
  constructor(bars, { reducedMotion } = {}) {
    this.bars = bars
    this.reducedMotion = reducedMotion
    this.reset()
  }

  start() {
    if (this.reducedMotion) return
    this.interval = setInterval(() => this.tick(), TICK_MS)
  }

  stop() {
    clearInterval(this.interval)
  }

  reset() {
    this.speaking = false
    this.tickCount = 0
    this.levels = this.bars.map(() => LEVEL_SILENT)
    this.render()
  }

  voice(on) {
    this.speaking = on

    if (this.reducedMotion) {
      this.levels = on ? staticSpeakingPattern(this.bars.length) : this.bars.map(() => LEVEL_SILENT)
      this.render()
    }
  }

  tick() {
    this.tickCount++
    const level = this.speaking
      ? 0.18 + (0.8 * Math.abs(Math.sin(this.tickCount * 1.3)) * (0.65 + (0.35 * Math.random())))
      : LEVEL_SILENT
    this.levels = [...this.levels.slice(1), level]
    this.render()
  }

  render() {
    const barCount = this.bars.length

    this.bars.forEach((bar, index) => {
      const level = this.levels[index]
      const fade = Math.min(1, (index + 1) / (barCount * 0.25))
      const speaking = level > LEVEL_VOICE_THRESHOLD

      bar.classList.toggle("bg-violet-600", speaking)
      bar.classList.toggle("bg-slate-400", !speaking)
      bar.style.height = `${speaking ? Math.max(3, level * 32) : 3}px`
      bar.style.opacity = speaking ? 0.35 + (0.65 * fade) : 0.5 + (0.5 * fade)
    })
  }
}
