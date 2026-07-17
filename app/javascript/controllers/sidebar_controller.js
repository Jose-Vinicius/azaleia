import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["nav", "text", "logoFull", "logoIcon", "userEmail", "userMenu"]

  connect() {
    this.isCollapsed = localStorage.getItem("sidebarState") === "collapsed"
    // Remove the transition briefly during initial load to prevent animation flash
    this.navTarget.style.transition = "none"
    this.updateUI()
    
    // Restore transition after a frame
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        this.navTarget.style.transition = ""
      })
    })
  }

  toggle() {
    this.isCollapsed = !this.isCollapsed
    localStorage.setItem("sidebarState", this.isCollapsed ? "collapsed" : "expanded")
    this.updateUI()
  }

  updateUI() {
    if (this.isCollapsed) {
      document.documentElement.classList.add("sidebar-collapsed")
      
      this.navTarget.classList.remove("w-64")
      this.navTarget.classList.add("w-20")
      
      this.textTargets.forEach(el => el.classList.add("hidden"))
      
      if (this.hasLogoFullTarget) this.logoFullTarget.classList.add("hidden")
      if (this.hasLogoIconTarget) this.logoIconTarget.classList.remove("hidden")
      if (this.hasUserEmailTarget) this.userEmailTarget.classList.add("hidden")
      
      if (this.hasUserMenuTarget) {
        this.userMenuTarget.classList.remove("left-3", "right-3", "bottom-full", "mb-1")
        this.userMenuTarget.classList.add("left-full", "bottom-0", "ml-2", "w-48")
      }
    } else {
      document.documentElement.classList.remove("sidebar-collapsed")
      
      this.navTarget.classList.remove("w-20")
      this.navTarget.classList.add("w-64")
      
      this.textTargets.forEach(el => el.classList.remove("hidden"))
      
      if (this.hasLogoFullTarget) this.logoFullTarget.classList.remove("hidden")
      if (this.hasLogoIconTarget) this.logoIconTarget.classList.add("hidden")
      if (this.hasUserEmailTarget) this.userEmailTarget.classList.remove("hidden")
      
      if (this.hasUserMenuTarget) {
        this.userMenuTarget.classList.remove("left-full", "bottom-0", "ml-2", "w-48")
        this.userMenuTarget.classList.add("left-3", "right-3", "bottom-full", "mb-1")
      }
    }
  }
}
