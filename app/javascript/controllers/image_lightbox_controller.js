import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "image", "counter", "filename", "zoomText", "downloadBtn", "openTabBtn"]
  static values = {
    images: Array,
    currentIndex: { type: Number, default: 0 },
    zoom: { type: Number, default: 1.0 }
  }

  connect() {
    this.boundKeydown = this.keydown.bind(this)
    this.boundWheel = this.wheel.bind(this)
    this.translateX = 0
    this.translateY = 0
    this.isDragging = false
    this.startX = 0
    this.startY = 0
  }

  disconnect() {
    window.removeEventListener("keydown", this.boundKeydown)
    if (this.hasImageTarget) {
      this.imageTarget.removeEventListener("wheel", this.boundWheel)
    }
  }

  open(event) {
    const index = parseInt(event.currentTarget.dataset.index || "0", 10)
    this.currentIndexValue = index
    this.zoomValue = 1.0
    this.translateX = 0
    this.translateY = 0
    
    this.modalTarget.classList.remove("hidden")
    window.addEventListener("keydown", this.boundKeydown)
    this.updateViewer()
  }

  close() {
    this.modalTarget.classList.add("hidden")
    window.removeEventListener("keydown", this.boundKeydown)
    this.resetPosition()
  }

  next() {
    if (!this.imagesValue.length) return
    this.currentIndexValue = (this.currentIndexValue + 1) % this.imagesValue.length
    this.zoomValue = 1.0
    this.resetPosition()
    this.updateViewer()
  }

  prev() {
    if (!this.imagesValue.length) return
    this.currentIndexValue = (this.currentIndexValue - 1 + this.imagesValue.length) % this.imagesValue.length
    this.zoomValue = 1.0
    this.resetPosition()
    this.updateViewer()
  }

  zoomIn() {
    this.zoomValue = Math.min(this.zoomValue + 0.25, 4.0)
    this.applyTransform()
  }

  zoomOut() {
    this.zoomValue = Math.max(this.zoomValue - 0.25, 0.5)
    if (this.zoomValue <= 1.0) {
      this.resetPosition()
    }
    this.applyTransform()
  }

  resetZoom() {
    this.zoomValue = 1.0
    this.resetPosition()
    this.applyTransform()
  }

  resetPosition() {
    this.translateX = 0
    this.translateY = 0
  }

  toggleDoubleTapZoom(event) {
    if (this.zoomValue === 1.0) {
      this.zoomValue = 2.0
    } else {
      this.zoomValue = 1.0
      this.resetPosition()
    }
    this.applyTransform()
  }

  startDrag(event) {
    event.preventDefault()
    this.isDragging = true

    const clientX = event.touches ? event.touches[0].clientX : event.clientX
    const clientY = event.touches ? event.touches[0].clientY : event.clientY

    this.startX = clientX - this.translateX
    this.startY = clientY - this.translateY

    if (this.hasImageTarget) {
      this.imageTarget.classList.remove("transition-transform")
      this.imageTarget.classList.add("cursor-grabbing")
    }
  }

  drag(event) {
    if (!this.isDragging) return
    event.preventDefault()

    const clientX = event.touches ? event.touches[0].clientX : event.clientX
    const clientY = event.touches ? event.touches[0].clientY : event.clientY

    this.translateX = clientX - this.startX
    this.translateY = clientY - this.startY

    this.applyTransform(false)
  }

  endDrag() {
    this.isDragging = false
    if (this.hasImageTarget) {
      this.imageTarget.classList.remove("cursor-grabbing")
      this.imageTarget.classList.add("transition-transform")
    }
  }

  wheel(event) {
    event.preventDefault()
    if (event.deltaY < 0) {
      this.zoomIn()
    } else if (event.deltaY > 0) {
      this.zoomOut()
    }
  }

  applyTransform(withTransition = true) {
    if (this.hasImageTarget) {
      if (withTransition) {
        this.imageTarget.style.transition = "transform 0.15s ease-out"
      } else {
        this.imageTarget.style.transition = "none"
      }
      this.imageTarget.style.transform = `translate(${this.translateX}px, ${this.translateY}px) scale(${this.zoomValue})`
    }

    if (this.hasZoomTextTarget) {
      this.zoomTextTarget.textContent = `${Math.round(this.zoomValue * 100)}%`
    }
  }

  updateViewer() {
    const current = this.imagesValue[this.currentIndexValue]
    if (!current) return

    if (this.hasImageTarget) {
      this.imageTarget.src = current.url
      this.imageTarget.alt = current.filename || "Imagem"
      this.imageTarget.removeEventListener("wheel", this.boundWheel)
      this.imageTarget.addEventListener("wheel", this.boundWheel, { passive: false })
    }

    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `${this.currentIndexValue + 1} de ${this.imagesValue.length}`
    }

    if (this.hasFilenameTarget) {
      this.filenameTarget.textContent = current.filename || ""
    }

    if (this.hasDownloadBtnTarget) {
      this.downloadBtnTarget.href = current.url
      this.downloadBtnTarget.setAttribute("download", current.filename || "imagem")
    }

    if (this.hasOpenTabBtnTarget) {
      this.openTabBtnTarget.href = current.url
    }

    this.applyTransform()
  }

  keydown(event) {
    if (this.modalTarget.classList.contains("hidden")) return

    switch (event.key) {
      case "Escape":
        this.close()
        break
      case "ArrowRight":
        this.next()
        break
      case "ArrowLeft":
        this.prev()
        break
      case "+":
      case "=":
        this.zoomIn()
        break
      case "-":
      case "_":
        this.zoomOut()
        break
      case "0":
        this.resetZoom()
        break
    }
  }
}
