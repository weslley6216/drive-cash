module SpeechRecognitionFake
  FAKE = <<~JS.freeze
    class FakeSpeechRecognition {
      start() {
        const sheet = document.querySelector('[data-speech-target="sheet"]')
        this.panelOpenAtStart = !!sheet && !sheet.classList.contains('invisible')
        this.started = true
        window.__speech = this
      }
      stop() { this.onend && this.onend() }
      abort() {
        this.onerror && this.onerror({ error: 'aborted' })
        this.onend && this.onend()
      }
    }
    window.SpeechRecognition = FakeSpeechRecognition
    window.webkitSpeechRecognition = FakeSpeechRecognition
  JS

  def install_fake_speech_recognition
    page.driver.browser.page.command('Page.addScriptToEvaluateOnNewDocument', source: FAKE)
  end

  def start_speaking
    page.execute_script('window.__speech.onspeechstart && window.__speech.onspeechstart()')
  end

  def hear(text, final: false)
    page.execute_script(<<~JS, text, final)
      const result = [{ transcript: arguments[0] }]
      result.isFinal = arguments[1]
      window.__speech.onresult({ resultIndex: 0, results: [result] })
    JS
  end

  def stop_speaking
    page.execute_script('window.__speech.onspeechend && window.__speech.onspeechend(); window.__speech.onend()')
  end

  def fail_hearing(error)
    page.execute_script("window.__speech.onerror({ error: '#{error}' }); window.__speech.onend()")
  end

  def wait_for_sheet_transition
    page.evaluate_async_script(<<~JS)
      const callback = arguments[arguments.length - 1]
      const sheet = document.querySelector('[data-speech-target="sheet"]')
      const done = () => callback(true)
      sheet.addEventListener('transitionend', done, { once: true })
      setTimeout(done, 500)
    JS
  end
end

RSpec.configure do |config|
  config.include SpeechRecognitionFake, type: :system
end
