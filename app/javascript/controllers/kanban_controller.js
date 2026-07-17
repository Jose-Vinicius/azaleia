import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["column", "dropzone", "card", "emptyState"]
  static values = { updateUrl: String }

  connect() {
    this.cardTargets.forEach(card => {
      card.addEventListener("dragstart", this.dragStart.bind(this))
      card.addEventListener("dragend", this.dragEnd.bind(this))
    })

    this.dropzoneTargets.forEach(zone => {
      zone.addEventListener("dragover", this.dragOver.bind(this))
      zone.addEventListener("dragenter", this.dragEnter.bind(this))
      zone.addEventListener("dragleave", this.dragLeave.bind(this))
      zone.addEventListener("drop", this.drop.bind(this))
    })
  }

  dragStart(event) {
    const card = event.target.closest("[data-kanban-target='card']")
    if (!card) return

    this.draggedCard = card
    card.classList.add("dragging")

    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", card.dataset.taskId)

    // Slightly delayed to allow the drag ghost to be created
    requestAnimationFrame(() => {
      card.style.opacity = "0.4"
    })
  }

  dragEnd(event) {
    const card = event.target.closest("[data-kanban-target='card']")
    if (!card) return

    card.classList.remove("dragging")
    card.style.opacity = ""
    this.draggedCard = null

    // Remove all column highlights
    this.columnTargets.forEach(col => col.classList.remove("drag-over"))
  }

  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
  }

  dragEnter(event) {
    event.preventDefault()
    const column = event.target.closest("[data-kanban-target='column']")
    if (column) {
      column.classList.add("drag-over")
    }
  }

  dragLeave(event) {
    const column = event.target.closest("[data-kanban-target='column']")
    if (column && !column.contains(event.relatedTarget)) {
      column.classList.remove("drag-over")
    }
  }

  async drop(event) {
    event.preventDefault()

    const dropzone = event.target.closest("[data-kanban-target='dropzone']")
    const column = event.target.closest("[data-kanban-target='column']")
    if (!dropzone || !this.draggedCard) return

    const taskId = event.dataTransfer.getData("text/plain")
    const newStatus = dropzone.dataset.status
    const card = this.draggedCard

    // Remove column highlights
    this.columnTargets.forEach(col => col.classList.remove("drag-over"))

    // Optimistic UI update: move card to new column
    dropzone.appendChild(card)
    card.classList.remove("dragging")
    card.style.opacity = ""

    // Hide empty states in target, show in source if needed
    this.updateEmptyStates()

    // Send PATCH request to update the task status
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    const url = `/tasks/${taskId}`

    try {
      const response = await fetch(url, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
          "Accept": "text/vnd.turbo-stream.html, text/html, application/json"
        },
        body: JSON.stringify({ task: { status: newStatus } })
      })

      if (!response.ok) {
        console.error("Failed to update task status:", response.status)
        // Could revert the optimistic update here
        window.location.reload()
      }
    } catch (error) {
      console.error("Error updating task status:", error)
      window.location.reload()
    }

    // Update column counters
    this.updateColumnCounts()
  }

  updateEmptyStates() {
    this.dropzoneTargets.forEach(zone => {
      const cards = zone.querySelectorAll("[data-kanban-target='card']")
      const emptyState = zone.querySelector("[data-kanban-target='emptyState']")
      if (emptyState) {
        emptyState.style.display = cards.length === 0 ? "" : "none"
      }
    })
  }

  updateColumnCounts() {
    this.columnTargets.forEach(column => {
      const dropzone = column.querySelector("[data-kanban-target='dropzone']")
      const cards = dropzone.querySelectorAll("[data-kanban-target='card']")
      const countBadge = column.querySelector(".kanban-count")
      if (countBadge) {
        countBadge.textContent = cards.length
      }

      // Also update the inline count badge (the one with rounded-full)
      const headerBadges = column.querySelectorAll("span.rounded-full")
      headerBadges.forEach(badge => {
        if (badge.textContent.trim().match(/^\d+$/)) {
          badge.textContent = cards.length
        }
      })
    })
  }
}
