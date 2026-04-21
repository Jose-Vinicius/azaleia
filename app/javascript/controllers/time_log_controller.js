import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["duration"]

  connect() {
    const block = localStorage.getItem("pomodoroBlockSize") || 30;
    if (this.hasDurationTarget) {
      this.durationTarget.value = block;
    }
  }
}
