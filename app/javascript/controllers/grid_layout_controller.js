import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.boundUpdateGrid = this.updateGrid.bind(this);
    window.addEventListener("settings:updated", this.boundUpdateGrid);
    this.updateGrid();
  }

  disconnect() {
    window.removeEventListener("settings:updated", this.boundUpdateGrid);
  }

  updateGrid() {
    this.element.querySelectorAll("[data-dashboard-card]").forEach(card => {
      const allTasks = Array.from(card.querySelectorAll("[data-task-item]"));
      
      // Hide the complete day card if there are no tasks inside
      if (allTasks.length === 0) {
        card.classList.add("hidden");
      } else {
        card.classList.remove("hidden");
      }
    });

    // Update grid configuration dynamically
    const visibleCards = this.element.querySelectorAll("[data-dashboard-card]:not(.hidden)");
    const savedCols = parseInt(localStorage.getItem("dashboardCols") || "3", 10);
    this.element.style.setProperty("--final-cols", Math.min(savedCols, Math.max(1, visibleCards.length)));
  }
}
