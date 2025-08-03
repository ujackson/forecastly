import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="components--ui--flash"
export default class extends Controller {
  dismiss() {
    this.element.remove()
  }
}
