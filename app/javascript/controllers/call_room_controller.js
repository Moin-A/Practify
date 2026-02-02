import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    apiKey: String,
    sessionId: String,
    token: String,
    userName: String,
    appointmentId: String,
    csrfToken: String
  }

  static targets = ["subscribers", "publisher", "micBtn", "camBtn"]

  connect() {
    fetch(`/appointments/${this.appointmentIdValue}/has_joined`, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': this.csrfTokenValue,
        'Accept': 'application/json'
      }
    })
    .then(response => response.json())
    .then(data => {
      console.log(data)
    })
    .catch(error => {
      console.error(error)
    })
    this.session = null
    this.publisher = null
    this.initializeSession()
  }

  disconnect() {
    if (this.session) {
      this.session.disconnect()
    }
  }

  initializeSession() {
    this.session = OT.initSession(this.apiKeyValue, this.sessionIdValue)

    this.session.on('streamCreated', (event) => {
      this.session.subscribe(event.stream, this.subscribersTarget, {
        insertMode: 'append',
        width: '100%',
        height: '100%'
      }, (error) => {
        if (error) console.error(error)
      })
    })

    this.session.connect(this.tokenValue, (error) => {
      if (error) {
        console.error(error)
      } else {
        this.publisher = OT.initPublisher(this.publisherTarget, {
          insertMode: 'append',
          width: '100%',
          height: '100%',
          name: this.userNameValue
        })
        this.session.publish(this.publisher)
      }
    })
  }

  toggleMic() {
    if (!this.publisher || !this.publisher.stream) return
    
    const isPublishing = this.publisher.stream.hasAudio
    this.publisher.publishAudio(!isPublishing)
    this.micBtnTarget.classList.toggle('off', isPublishing)
  }

  toggleCam() {
    if (!this.publisher || !this.publisher.stream) return
    
    const isPublishing = this.publisher.stream.hasVideo
    this.publisher.publishVideo(!isPublishing)
    this.camBtnTarget.classList.toggle('off', isPublishing)
  }

  leaveSession() {
    if (this.session) {
      this.session.disconnect()
    }
    window.location.href = '/'
  }
}
