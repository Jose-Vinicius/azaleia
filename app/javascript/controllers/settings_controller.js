import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dashboardCols", "pomodoroBlock", "notificationLead", "notificationBtn", "notificationBtnText"]

  connect() {
    const savedCols = localStorage.getItem("dashboardCols") || 3;
    if (this.hasDashboardColsTarget) {
      this.dashboardColsTarget.value = Math.min(Math.max(savedCols, 3), 7);
    }

    const savedBlock = localStorage.getItem("pomodoroBlockSize") || 30;
    if (this.hasPomodoroBlockTarget) {
      this.pomodoroBlockTarget.value = Math.min(Math.max(savedBlock, 5), 180);
    }

    const savedLead = localStorage.getItem("notificationLeadTime") || 10;
    if (this.hasNotificationLeadTarget) {
      this.notificationLeadTarget.value = Math.max(savedLead, 0);
    }
    
    this.updateNotificationBtn();
  }

  updateNotificationBtn() {
    if (!this.hasNotificationBtnTarget) return;

    const isEnabled = localStorage.getItem("notificationsEnabled") === "true";
    const icon = this.notificationBtnTarget.querySelector(".material-symbols-outlined");

    if (isEnabled) {
      this.notificationBtnTextTarget.textContent = "Desativar Notificações do Sistema";
      icon.textContent = "notifications_off";
      this.notificationBtnTarget.classList.remove("bg-surface-container", "text-on-surface", "border-outline-variant");
      this.notificationBtnTarget.classList.add("bg-error/10", "text-error", "border-error/20");
    } else {
      this.notificationBtnTextTarget.textContent = "Ativar Notificações no Sistema";
      icon.textContent = "notifications_active";
      this.notificationBtnTarget.classList.remove("bg-error/10", "text-error", "border-error/20");
      this.notificationBtnTarget.classList.add("bg-surface-container", "text-on-surface", "border-outline-variant");
    }
  }

  toggleNotificationPermission(event) {
    event.preventDefault();
    
    const isEnabled = localStorage.getItem("notificationsEnabled") === "true";
    
    if (isEnabled) {
      localStorage.setItem("notificationsEnabled", "false");
      this.updateNotificationBtn();
      return;
    }

    if (!("Notification" in window)) {
      alert("Seu navegador não suporta notificações de sistema.");
      return;
    }
    
    if (window.isSecureContext === false) {
      alert("As notificações nativas exigem uma conexão segura (HTTPS ou localhost).");
      return;
    }

    if (Notification.permission === "granted") {
      localStorage.setItem("notificationsEnabled", "true");
      this.updateNotificationBtn();
    } else {
      Notification.requestPermission().then(permission => {
        if (permission === "granted") {
          localStorage.setItem("notificationsEnabled", "true");
          this.updateNotificationBtn();
          new Notification("Azaleia", { body: "As notificações foram ativadas com sucesso!" });
        } else {
          alert("Permissão para notificações foi negada.");
        }
      });
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

    if (this.hasNotificationLeadTarget) {
      const value = Math.max(this.notificationLeadTarget.value, 0);
      localStorage.setItem("notificationLeadTime", value);
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
