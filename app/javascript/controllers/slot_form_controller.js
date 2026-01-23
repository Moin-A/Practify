import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="slot-form"
export default class extends Controller {
  static targets = ["startAt", "endAt"]

  updateEndTime() {
    const startTime = new Date(this.startAtTarget.value)
    if (startTime && !isNaN(startTime.getTime())) {
      // Add 1 hour to start time
      const endTime = new Date(startTime.getTime() + (60 * 60 * 1000)) // 1 hour in milliseconds

      // Format for datetime-local input (YYYY-MM-DDTHH:mm) in local timezone
      const year = endTime.getFullYear()
      const month = String(endTime.getMonth() + 1).padStart(2, '0')
      const day = String(endTime.getDate()).padStart(2, '0')
      const hours = String(endTime.getHours()).padStart(2, '0')
      const minutes = String(endTime.getMinutes()).padStart(2, '0')

      const formattedEndTime = `${year}-${month}-${day}T${hours}:${minutes}`
      this.endAtTarget.value = formattedEndTime
    }
  }
}