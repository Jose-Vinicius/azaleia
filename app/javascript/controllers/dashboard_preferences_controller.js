import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["periodSelect", "cardsBtn", "listBtn", "frame"]

  connect() {
    this.period = localStorage.getItem("dashboard_filter_period") || "week"
    this.viewMode = localStorage.getItem("dashboard_view_mode") || "cards"
    
    // We only want to trigger a fetch if localStorage differs from the server-rendered default
    // Or if we need to sync the UI state.
    
    // Read the current server state from the select if possible
    const currentServerPeriod = this.periodSelectTarget.value
    // Read current view_mode from UI classes
    const currentServerViewMode = this.cardsBtnTarget.classList.contains("text-primary") ? "cards" : "list"
    
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

  updateButtons() {
    if (this.viewMode === "cards") {
      this.cardsBtnTarget.classList.add("bg-primary/20", "text-primary")
      this.cardsBtnTarget.classList.remove("text-on-surface-variant")
      this.listBtnTarget.classList.add("text-on-surface-variant")
      this.listBtnTarget.classList.remove("bg-primary/20", "text-primary")
    } else {
      this.listBtnTarget.classList.add("bg-primary/20", "text-primary")
      this.listBtnTarget.classList.remove("text-on-surface-variant")
      this.cardsBtnTarget.classList.add("text-on-surface-variant")
      this.cardsBtnTarget.classList.remove("bg-primary/20", "text-primary")
    }
  }

  loadContent() {
    const url = new URL(window.location.href)
    url.searchParams.set("filter_period", this.period)
    url.searchParams.set("view_mode", this.viewMode)
    
    // Setting frame src triggers a fetch and update by Turbo
    this.frameTarget.src = url.toString()
  }
}
