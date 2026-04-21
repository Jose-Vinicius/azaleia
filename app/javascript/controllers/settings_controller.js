import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "dashboardCols", "pomodoroBlock" ]

  connect() {
    const savedCols = localStorage.getItem("dashboardCols") || 3;
    if (this.hasDashboardColsTarget) {
      this.dashboardColsTarget.value = Math.min(Math.max(savedCols, 3), 7);
    }
    
    const savedBlock = localStorage.getItem("pomodoroBlockSize") || 30;
    if (this.hasPomodoroBlockTarget) {
      this.pomodoroBlockTarget.value = Math.min(Math.max(savedBlock, 5), 180);
    }
  }

  save() {
    if (this.hasDashboardColsTarget) {
      const value = Math.min(Math.max(this.dashboardColsTarget.value, 3), 7);
      localStorage.setItem("dashboardCols", value);
      document.documentElement.style.setProperty('--desktop-cols', value);
      window.dispatchEvent(new Event("settings:updated"));
    }
    
    if (this.hasPomodoroBlockTarget) {
      const value = Math.min(Math.max(this.pomodoroBlockTarget.value, 5), 180);
      localStorage.setItem("pomodoroBlockSize", value);
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
