import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["periodSelect", "cardsBtn", "listBtn", "calendarBtn", "frame"]

  connect() {
    this.period = localStorage.getItem("dashboard_filter_period") || "week"
    this.viewMode = localStorage.getItem("dashboard_view_mode") || "cards"
    
    // We only want to trigger a fetch if localStorage differs from the server-rendered default
    // Or if we need to sync the UI state.
    
    // Read the current server state from the select if possible
    const currentServerPeriod = this.periodSelectTarget.value
    // Read current view_mode from UI classes
    let currentServerViewMode = "list"
    if (this.cardsBtnTarget.classList.contains("text-primary")) {
      currentServerViewMode = "cards"
    } else if (this.calendarBtnTarget && this.calendarBtnTarget.classList.contains("text-primary")) {
      currentServerViewMode = "calendar"
    }
    
    // If local storage differs from server state, update UI and fetch
    if (this.period !== currentServerPeriod || this.viewMode !== currentServerViewMode) {
      this.periodSelectTarget.value = this.period
      this.updateButtons()
      this.loadContent()
    }
  }

  updatePeriod(event) {
    this.period = event.target.value
    localStorage.setItem("dashboard_filter_period", this.period)
    this.loadContent()
  }

  setViewCards(event) {
    event.preventDefault()
    if (this.viewMode === "cards") return;
    this.viewMode = "cards"
    localStorage.setItem("dashboard_view_mode", this.viewMode)
    this.updateButtons()
    this.loadContent()
  }

  setViewList(event) {
    event.preventDefault()
    if (this.viewMode === "list") return;
    this.viewMode = "list"
    localStorage.setItem("dashboard_view_mode", this.viewMode)
    this.updateButtons()
    this.loadContent()
  }

  setViewCalendar(event) {
    event.preventDefault()
    if (this.viewMode === "calendar") return;
    this.viewMode = "calendar"
    localStorage.setItem("dashboard_view_mode", this.viewMode)
    this.updateButtons()
    this.loadContent()
  }

  updateButtons() {
    const activeClasses = ["bg-primary/20", "text-primary"]
    const inactiveClasses = ["text-on-surface-variant"]

    const buttons = {
      "cards": this.cardsBtnTarget,
      "list": this.listBtnTarget,
      "calendar": this.hasCalendarBtnTarget ? this.calendarBtnTarget : null
    }

    Object.entries(buttons).forEach(([mode, btn]) => {
      if (!btn) return;
      if (this.viewMode === mode) {
        btn.classList.add(...activeClasses)
        btn.classList.remove(...inactiveClasses)
      } else {
        btn.classList.add(...inactiveClasses)
        btn.classList.remove(...activeClasses)
      }
    })
  }

  loadContent() {
    const url = new URL(window.location.href)
    url.searchParams.set("filter_period", this.period)
    url.searchParams.set("view_mode", this.viewMode)
    
    // Setting frame src triggers a fetch and update by Turbo
    this.frameTarget.src = url.toString()
  }
}
