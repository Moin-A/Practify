import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tabs"
export default class extends Controller {
  static targets = ["signIn", "signUp", "signInForm", "signUpForm", "notes", "observations"]



  connect() {
    const button_style = ["rounded-md", "shadow-sm", "border", "border-[#EEE]", "text-[#111]", "bg-white"]
    this.signInTarget.addEventListener("click", (event) => {

      event.target.classList.add(...button_style)
      this.signUpTarget.classList.remove(...button_style)
      this.signInFormTarget.classList.remove("hidden")
      this.signUpFormTarget.classList.add("hidden")

    })
    this.signUpTarget.addEventListener("click", (event) => {
      event.target.classList.add(...button_style)
      this.signInTarget.classList.remove(...button_style)
      this.signUpFormTarget.classList.remove("hidden")
      this.signInFormTarget.classList.add("hidden")


    })
  }
}
