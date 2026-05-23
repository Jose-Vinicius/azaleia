import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.checkInterval = 30 * 1000 // 30 seconds
    this.notifiedTaskIds = new Set()
    
    // Check immediately, then every 30 seconds
    this.checkUpcomingTasks()
    this.intervalId = setInterval(() => this.checkUpcomingTasks(), this.checkInterval)
  }

  disconnect() {
    clearInterval(this.intervalId)
  }

  async checkUpcomingTasks() {
    try {
      const response = await fetch("/tasks/upcoming.json")
      if (!response.ok) return
      
      const tasks = await response.json()
      const leadTimeMinutes = parseInt(localStorage.getItem("notificationLeadTime") || "10", 10)
      const leadTimeMs = leadTimeMinutes * 60 * 1000
      
      const now = new Date().getTime()
      
      tasks.forEach(task => {
        if (!task.schedule_at || this.notifiedTaskIds.has(task.id + task.schedule_at)) return
        
        const taskTime = new Date(task.schedule_at).getTime()
        const targetNotifyTime = taskTime - leadTimeMs
        
        // If we are within the notification window (e.g. exactly at the notify time or up to 2 mins after)
        // We give a small buffer in case the interval missed the exact millisecond.
        const timeDiff = now - targetNotifyTime
        
        if (timeDiff >= 0 && timeDiff <= 2 * 60 * 1000) {
          this.notifyTask(task, leadTimeMinutes)
          this.notifiedTaskIds.add(task.id + task.schedule_at)
        }
      })
    } catch (e) {
      console.error("Failed to fetch upcoming tasks for notifications:", e)
    }
  }

  notifyTask(task, leadTime) {
    const timeMessage = leadTime === 0 ? "começa agora!" : `começa em ${leadTime} minutos.`
    const message = `Sua tarefa "${task.title}" ${timeMessage}`
    
    // 1. In-App Toast
    this.showToast(task.title, timeMessage)
    
    // 2. Native Browser Notification (if permitted, secure, and enabled)
    const isEnabled = localStorage.getItem("notificationsEnabled") === "true"
    if (isEnabled && "Notification" in window && window.isSecureContext) {
      if (Notification.permission === "granted") {
        new Notification("Azaleia", { body: message })
      }
    }

    // 3. Persist in Database (Notification Center)
    this.persistNotification(task.id, message)
  }

  async persistNotification(taskId, message) {
    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
      
      // Request Turbo Stream response so it can update the badge automatically if we want
      await fetch('/notifications', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'text/vnd.turbo-stream.html, text/html, application/xhtml+xml',
          'X-CSRF-Token': csrfToken
        },
        body: JSON.stringify({ task_id: taskId, message: message })
      }).then(response => response.text())
        .then(html => Turbo.renderStreamMessage(html));
    } catch (e) {
      console.error("Failed to persist notification:", e);
    }
  }

  showToast(title, message) {
    const container = document.getElementById("toasts-container")
    if (!container) return
    
    const toastHTML = `
      <div data-controller="toast" class="pointer-events-auto w-[350px] bg-surface-container-high border border-outline-variant rounded-xl shadow-2xl p-4 flex gap-3 transform transition-all duration-300 opacity-0 translate-y-4 scale-95">
        <div class="flex-shrink-0 pt-0.5">
          <div class="w-8 h-8 rounded-full bg-primary/20 flex items-center justify-center text-primary">
            <span class="material-symbols-outlined text-[18px]" style="font-variation-settings: 'FILL' 1;">notifications_active</span>
          </div>
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-bold text-on-surface truncate">${title}</p>
          <p class="text-xs font-medium text-on-surface-variant mt-0.5">${message}</p>
        </div>
        <button data-action="click->toast#close" class="flex-shrink-0 text-on-surface-variant hover:text-on-surface transition-colors p-1 rounded-lg hover:bg-surface-variant h-fit flex items-center justify-center">
          <span class="material-symbols-outlined text-[16px]">close</span>
        </button>
      </div>
    `
    container.insertAdjacentHTML('beforeend', toastHTML)
  }
}
