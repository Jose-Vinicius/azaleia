import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "dashboardCols" ]

  connect() {
    const savedCols = localStorage.getItem("dashboardCols") || 3;
    if (this.hasDashboardColsTarget) {
      this.dashboardColsTarget.value = Math.min(Math.max(savedCols, 3), 7);
    }
  }

  save() {
    if (this.hasDashboardColsTarget) {
      const value = Math.min(Math.max(this.dashboardColsTarget.value, 3), 7);
      localStorage.setItem("dashboardCols", value);
      document.documentElement.style.setProperty('--desktop-cols', value);
      window.dispatchEvent(new Event("settings:updated"));
    }
    
    this.close();
  }

  close() {
    const modal = document.getElementById("modal");
    if (modal) {
      modal.innerHTML = "";
    }
  }
}
