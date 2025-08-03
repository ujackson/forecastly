import { Controller } from "@hotwired/stimulus"
import { Spinner } from "spin.js"

export default class extends Controller {
  static targets = ["overlay", "spinner"]

  connect() {
    this.spinner = null

    // Listen for custom spinner events globally
    document.addEventListener("startSpinner", (event) => {this.start()})
    document.addEventListener("stopSpinner", () => this.stop())
  }

  // Start spinner
  start() {
    const opts = {
      lines: 8,
      length: 28,
      width: 17,
      radius: 25,
      corners: 1,
      scale: 1,
      rotate: 0,
      direction: 1,
      color: "#333333",
      speed: 1.2,
      trail: 70,
      shadow: false,
      hwaccel: false,
      className: "spinner",
      zIndex: 29000,
    }

    if (!this.spinner) {
      this.spinner = new Spinner(opts).spin()
      this.spinnerTarget.appendChild(this.spinner.el)
      this.overlayTarget.style.display = "block"
    }
  }

  // Stop spinner
  stop() {
    if (this.spinner) {
      setTimeout(() => {
        this.spinner?.stop()
        this.spinner = null
        this.spinnerTarget.innerHTML = ""
        this.overlayTarget.style.display = "none"
      }, 1000)
    }
  }
}