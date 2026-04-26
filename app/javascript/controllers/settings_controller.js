import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dashboardCols", "pomodoroBlock"]

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

  toggleSwitch(event) {
    const btn = event.currentTarget;
    const isChecked = btn.getAttribute("aria-checked") === "true";
    this.updateSwitchVisual(btn, !isChecked);
  }

  updateSwitchVisual(btn, checked) {
    btn.setAttribute("aria-checked", checked ? "true" : "false");
    const dot = btn.querySelector("span");
    if (checked) {
      btn.classList.remove("bg-outline");
      btn.classList.add("bg-primary");
      dot.classList.remove("translate-x-0");
      dot.classList.add("translate-x-5");
    } else {
      btn.classList.remove("bg-primary");
      btn.classList.add("bg-outline");
      dot.classList.remove("translate-x-5");
      dot.classList.add("translate-x-0");
    }
  }

  save() {
    if (this.hasDashboardColsTarget) {
      const value = Math.min(Math.max(this.dashboardColsTarget.value, 3), 7);
      localStorage.setItem("dashboardCols", value);
      document.documentElement.style.setProperty('--desktop-cols', value);
    }

    if (this.hasPomodoroBlockTarget) {
      const value = Math.min(Math.max(this.pomodoroBlockTarget.value, 5), 180);
      localStorage.setItem("pomodoroBlockSize", value);
    }

    window.dispatchEvent(new Event("settings:updated"));
    this.close();
  }

  close() {
    const modal = document.getElementById("modal");
    if (modal) {
      modal.innerHTML = "";
    }
  }
}
