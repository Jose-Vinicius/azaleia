import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.boundUpdateGrid = this.updateGrid.bind(this);
    
    // Observers watch for Turbo Streams appending new cards dynamically
    this.observer = new MutationObserver(this.boundUpdateGrid);
    this.observer.observe(this.element, { childList: true });
    
    window.addEventListener("settings:updated", this.boundUpdateGrid);
    this.updateGrid();
  }

  disconnect() {
    this.observer.disconnect();
    window.removeEventListener("settings:updated", this.boundUpdateGrid);
  }

  updateGrid() {
    const savedCols = parseInt(localStorage.getItem("dashboardCols") || "3", 10);
    const count = this.element.children.length;
    this.element.style.setProperty("--final-cols", Math.min(savedCols, Math.max(1, count)));
  }
}
