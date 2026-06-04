import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "nameField", "nameError", "nameValidIcon", "nameErrorIcon",
    "emailAddressField", "emailAddressError", "emailAddressValidIcon", "emailAddressErrorIcon",
    "passwordField", "passwordError",
    "passwordConfirmationField", "passwordConfirmationError",
    "submitButton"
  ]

  #touched = new Set()
  #valid = new Set()

  validate({ target }) {
    const field = target.dataset.registrationFormField
    if (!field) return
    this.#touched.add(field)
    this.#validateField(field)
  }

  #validateField(field) {
    let message
    switch (field) {
      case "name":
        message = this.nameFieldTarget.value.trim() ? null : "Nome não pode ficar em branco"
        this.#applyTextState(this.nameFieldTarget, this.nameErrorTarget, this.nameValidIconTarget, this.nameErrorIconTarget, message)
        break
      case "email_address":
        message = this.#emailError(this.emailAddressFieldTarget.value.trim())
        this.#applyTextState(this.emailAddressFieldTarget, this.emailAddressErrorTarget, this.emailAddressValidIconTarget, this.emailAddressErrorIconTarget, message)
        break
      case "password":
        message = this.#passwordError(this.passwordFieldTarget.value)
        this.#applyPasswordState(this.passwordFieldTarget, this.passwordErrorTarget, message)
        if (this.#touched.has("password_confirmation")) this.#validateField("password_confirmation")
        break
      case "password_confirmation":
        message = this.passwordConfirmationFieldTarget.value === this.passwordFieldTarget.value
          ? null
          : "As senhas não coincidem"
        this.#applyPasswordState(this.passwordConfirmationFieldTarget, this.passwordConfirmationErrorTarget, message)
        break
    }
    if (message === null) {
      this.#valid.add(field)
    } else {
      this.#valid.delete(field)
    }
    this.#updateSubmitButton()
  }

  #updateSubmitButton() {
    const allValid = ["name", "email_address", "password", "password_confirmation"]
      .every(field => this.#valid.has(field))
    this.submitButtonTarget.disabled = !allValid
  }

  #applyTextState(inputEl, errorEl, validIconEl, errorIconEl, message) {
    this.#setInputClasses(inputEl, message ? "error" : "valid")
    validIconEl.classList.toggle("hidden", !!message)
    errorIconEl.classList.toggle("hidden", !message)
    errorEl.textContent = message || ""
    errorEl.classList.toggle("hidden", !message)
  }

  #applyPasswordState(inputEl, errorEl, message) {
    this.#setInputClasses(inputEl, message ? "error" : "valid")
    errorEl.textContent = message || ""
    errorEl.classList.toggle("hidden", !message)
  }

  #setInputClasses(inputEl, state) {
    inputEl.classList.remove(
      "border-slate-200", "bg-white",
      "border-red-400", "bg-red-50",
      "border-green-500", "bg-green-50"
    )
    if (state === "error") {
      inputEl.classList.add("border-red-400", "bg-red-50")
    } else {
      inputEl.classList.add("border-green-500", "bg-green-50")
    }
  }

  #emailError(value) {
    if (!value) return "E-mail não pode ficar em branco"
    if (!/\S+@\S+\.\S+/.test(value)) return "E-mail inválido"
    return null
  }

  #passwordError(value) {
    if (!value) return "Senha não pode ficar em branco"
    if (value.length < 8) return "Mínimo 8 caracteres"
    return null
  }
}
