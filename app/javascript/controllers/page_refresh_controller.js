import { Controller } from "@hotwired/stimulus"

// This controller triggers a Turbo page visit when connected to the DOM.
// Used by turbo_stream responses to reload the page after modal actions.
export default class extends Controller {
  connect() {
    const dashboardFrame = document.getElementById("dashboard_content")
    
    if (dashboardFrame) {
      const url = new URL(window.location.href)
      const period = localStorage.getItem("dashboard_filter_period") || "week"
      const viewMode = localStorage.getItem("dashboard_view_mode") || "cards"
      
      url.searchParams.set("filter_period", period)
      url.searchParams.set("view_mode", viewMode)
      
      const targetSrc = url.toString()
      
      if (dashboardFrame.src === targetSrc) {
        if (typeof dashboardFrame.reload === "function") {
          dashboardFrame.reload()
        } else {
          dashboardFrame.src = targetSrc
        }
      } else {
        dashboardFrame.src = targetSrc
      }
    } else {
      Turbo.visit(window.location.href, { action: "replace" })
    }
  }
}
