import { Controller } from "@hotwired/stimulus"

const MAX_WIDTH = 400
const MAX_HEIGHT = 200
const QUALITY = 0.85

export default class extends Controller {
  connect() {
    this.element.addEventListener("trix-attachment-add", this.handleAttachment)
  }

  disconnect() {
    this.element.removeEventListener("trix-attachment-add", this.handleAttachment)
  }

  handleAttachment = (event) => {
    const { attachment } = event
    if (!attachment.file) return
    if (!attachment.file.type.startsWith("image/")) return

    const reader = new FileReader()
    reader.onload = (e) => {
      const img = new Image()
      img.onload = () => {
        let { width, height } = img

        // Skip if already within limits
        if (width <= MAX_WIDTH && height <= MAX_HEIGHT) return

        const ratio = Math.min(MAX_WIDTH / width, MAX_HEIGHT / height)
        width = Math.round(width * ratio)
        height = Math.round(height * ratio)

        const canvas = document.createElement("canvas")
        canvas.width = width
        canvas.height = height
        canvas.getContext("2d").drawImage(img, 0, 0, width, height)

        canvas.toBlob((blob) => {
          const resizedFile = new File([blob], attachment.file.name, { type: attachment.file.type })
          attachment.setFile(resizedFile)
        }, attachment.file.type, QUALITY)
      }
      img.src = e.target.result
    }
    reader.readAsDataURL(attachment.file)
  }
}
