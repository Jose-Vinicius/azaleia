import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Animate in
    requestAnimationFrame(() => {
      this.element.classList.remove("opacity-0", "translate-y-4", "scale-95")
      this.element.classList.add("opacity-100", "translate-y-0", "scale-100")
    })

    // Auto dismiss after 5 seconds
    this.timeout = setTimeout(() => {
      this.close()
    }, 5000)
  }

  close() {
    clearTimeout(this.timeout)
    // Animate out
    this.element.classList.remove("opacity-100", "translate-y-0", "scale-100")
    this.element.classList.add("opacity-0", "-translate-y-4", "scale-95")
    
    // Remove element after transition
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
