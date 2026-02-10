import { Controller } from "@hotwired/stimulus"
import OT from "@opentok/client"

export default class extends Controller {
  static values = {
    apiKey: String,
    sessionId: String,
    token: String,
    userName: String,
    appointmentId: String,
    csrfToken: String
  }

  static targets = ["subscribers", "publisher", "micBtn", "camBtn", "endBtn", "chatMessages", "chatInput", "errorMessage"]

  connect() {
    console.log('call-room #connect')

    // Validate required values before proceeding
    if (!this.validateRequiredValues()) {
      return // Stop here if validation fails
    }

    // Enable OpenTok logging for debugging
    OT.setLogLevel(OT.DEBUG)

    // Log what we're working with
    console.log('OpenTok Configuration:', {
      apiKey: this.apiKeyValue ? `${this.apiKeyValue.substring(0, 8)}...` : 'MISSING',
      sessionId: this.sessionIdValue ? `${this.sessionIdValue.substring(0, 15)}...` : 'MISSING',
      token: this.tokenValue ? 'Present' : 'MISSING',
      userName: this.userNameValue,
      appointmentId: this.appointmentIdValue
    })

    this.notifyHasJoined()

    this.session = null
    this.publisher = null
    this.publishAttempts = 0
    this.maxPublishAttempts = 3
    this.initializeSession()
  }

  validateRequiredValues() {
    const errors = []

    if (!this.apiKeyValue || this.apiKeyValue === '') {
      errors.push('API Key is missing')
    }

    if (!this.sessionIdValue || this.sessionIdValue === '') {
      errors.push('Session ID is missing')
    }

    if (!this.tokenValue || this.tokenValue === '') {
      errors.push('Token is missing')
    }

    if (!this.userNameValue || this.userNameValue === '') {
      errors.push('User name is missing')
    }

    if (errors.length > 0) {
      const errorMessage = `
        <strong>Configuration Error:</strong><br>
        ${errors.join('<br>')}
        <br><br>
        <small>Please refresh the page or contact support if this persists.</small>
      `
      this.showError(errorMessage, 'error')
      console.error('OpenTok configuration errors:', errors)
      console.error('Check your Rails controller - make sure these variables are set:', {
        '@app_id': this.apiKeyValue,
        '@session_id': this.sessionIdValue,
        '@token': this.tokenValue,
        'current_user.name': this.userNameValue
      })
      return false
    }

    return true
  }

  notifyHasJoined() {
    fetch(`/appointments/${this.appointmentIdValue}/has_joined`, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': this.csrfTokenValue,
        'Accept': 'application/json'
      }
    })
      .then(response => response.json())
      .then(data => {
        console.log('Has joined notification sent:', data)
      })
      .catch(error => {
        console.error('Error sending has_joined notification:', error)
      })
  }

  disconnect() {
    console.log('call-room #disconnect')
    if (this.publisher) {
      this.publisher.destroy()
      this.publisher = null
    }
    if (this.session) {
      this.session.disconnect()
      this.session = null
    }
  }

  initializeSession() {
    console.log('Initializing session...')
    this.session = OT.initSession(this.apiKeyValue, this.sessionIdValue)

    // Handle connection events
    this.session.on('sessionConnected', (event) => {
      console.log('✓ Session connected successfully')
      this.clearError()
    })

    this.session.on('sessionDisconnected', (event) => {
      console.log('Session disconnected:', event.reason)
      if (event.reason === 'networkDisconnected') {
        this.showError('Connection lost. Please check your internet connection.', 'warning')
      }
    })

    this.session.on('sessionReconnecting', (event) => {
      console.log('Session reconnecting...')
      this.showError('Reconnecting...', 'warning')
    })

    this.session.on('sessionReconnected', (event) => {
      console.log('✓ Session reconnected')
      this.clearError()
    })

    // Subscribe to new streams
    this.session.on('streamCreated', (event) => {
      console.log('Stream created:', event.stream.name)
      const subscriber = this.session.subscribe(event.stream, this.subscribersTarget, {
        insertMode: 'append',
        width: '100%',
        height: '100%',
        preferredFrameRate: 30,
        preferredResolution: '1280x720'
      }, (error) => {
        if (error) {
          console.error('Subscribe error:', error)
          this.showError(`Failed to subscribe: ${error.message}`, 'error')
        } else {
          console.log('✓ Subscribed to stream successfully')
        }
      })

      subscriber.on('videoElementCreated', (event) => {
        console.log('Subscriber video element created')
      })
    })

    this.session.on('streamDestroyed', (event) => {
      console.log('Stream destroyed:', event.stream.name)
    })

    // Chat functionality
    this.session.on('signal:chat', (event) => {
      this.displayChatMessage(event.data, event.from.connectionId === this.session.connection.connectionId)
    })

    // Connection monitoring
    this.session.on('connectionCreated', (event) => {
      console.log('Connection created:', event.connection.connectionId)
    })

    this.session.on('connectionDestroyed', (event) => {
      console.log('Connection destroyed:', event.connection.connectionId)
    })

    // Connect to session
    console.log('Connecting to session...')
    this.session.connect(this.tokenValue, (error) => {
      if (error) {
        console.error('✗ Error connecting to session:', error)
        this.showError(`Connection failed: ${error.message}`, 'error')
      } else {
        console.log('✓ Connected to session')
        // Delay publishing slightly to ensure connection is stable
        setTimeout(() => this.publishStream(), 500)
      }
    })
  }

  publishStream() {
    this.publishAttempts++
    console.log(`Publishing stream (attempt ${this.publishAttempts}/${this.maxPublishAttempts})`)

    const publisherOptions = {
      insertMode: 'append',
      width: '100%',
      height: '100%',
      name: this.userNameValue,
      publishAudio: true,
      publishVideo: true,
      preferredFrameRate: 30,
      preferredResolution: '1280x720',
      mirror: true,
      audioFallbackEnabled: true,
      audioSource: undefined,
      videoSource: undefined
    }

    this.publisher = OT.initPublisher(
      this.publisherTarget,
      publisherOptions,
      (error) => {
        if (error) {
          console.error('✗ Error initializing publisher:', error)
          this.showError(`Camera/Microphone access failed: ${error.message}`, 'error')

          if (error.name === 'OT_USER_MEDIA_ACCESS_DENIED') {
            this.showError('Please allow camera and microphone access in your browser settings.', 'error')
          }
        } else {
          console.log('✓ Publisher initialized successfully')

          this.session.publish(this.publisher, (publishError) => {
            if (publishError) {
              console.error('✗ Error publishing:', publishError)

              if (publishError.code === 1500) {
                this.handlePublishTimeout()
              } else {
                this.showError(`Publishing failed: ${publishError.message}`, 'error')
              }
            } else {
              console.log('✓ Publishing stream successfully')
              this.clearError()
            }
          })
        }
      }
    )

    // Publisher events
    this.publisher.on('streamCreated', (event) => {
      console.log('✓ Publisher stream created')
    })

    this.publisher.on('streamDestroyed', (event) => {
      console.log('Publisher stream destroyed:', event.reason)
    })

    this.publisher.on('publishingError', (event) => {
      console.error('✗ Publishing error:', event)
      this.showError(`Publishing error: ${event.message || 'Unknown error'}`, 'error')
    })
  }

  handlePublishTimeout() {
    console.error('✗ Publish timeout - ICE connection failed')

    if (this.publishAttempts < this.maxPublishAttempts) {
      this.showError(
        `Connection timeout. Retrying (${this.publishAttempts}/${this.maxPublishAttempts})...`,
        'warning'
      )

      if (this.publisher) {
        this.publisher.destroy()
        this.publisher = null
      }

      setTimeout(() => this.publishStream(), 2000)
    } else {
      this.showError(
        'Unable to connect. This may be due to firewall restrictions. ' +
        'Please check your network settings or try a different network.',
        'error'
      )
      this.showFirewallHelp()
    }
  }

  showFirewallHelp() {
    console.log(`
╔════════════════════════════════════════════════════════════════╗
║              OPENTOK CONNECTION TROUBLESHOOTING                ║
╚════════════════════════════════════════════════════════════════╝

Error 1500 typically means:
1. Firewall is blocking WebRTC connections
2. Corporate network restrictions
3. VPN interference
4. Router/NAT configuration issues

SOLUTIONS:
✓ Try mobile hotspot
✓ Disable VPN
✓ Use different browser (Chrome recommended)
✓ Check firewall allows UDP ports 3478-3479

For details, see ERROR_1500_TROUBLESHOOTING.md
    `)
  }

  toggleMic() {
    if (this.publisher) {
      const enabled = this.publisher.stream?.hasAudio !== false
      this.publisher.publishAudio(!enabled)
      this.micBtnTarget.classList.toggle('muted', enabled)
      this.micBtnTarget.textContent = enabled ? '🔇 Unmute' : '🎤 Mute'
      console.log(`Microphone ${enabled ? 'muted' : 'unmuted'}`)
    }
  }

  toggleCam() {
    debugger
    console.log('call-room #toggleCam')
    const enabled = this.publisher.stream?.hasVideo !== false
    this.publisher.publishVideo(!enabled)
    this.camBtnTarget.classList.toggle('disabled', enabled)
    debugger
    this.camBtnTarget.innerHTML = enabled
      ? `
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="size-6">
          <path d="M4.5 4.5a3 3 0 0 0-3 3v9a3 3 0 0 0 3 3h8.25a3 3 0 0 0 3-3v-9a3 3 0 0 0-3-3H4.5ZM19.94 18.75l-2.69-2.69V7.94l2.69-2.69c.944-.945 2.56-.276 2.56 1.06v11.38c0 1.336-1.616 2.005-2.56 1.06Z" />
        </svg>
        <span>Start Video</span>
      `
      : `
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="size-6">
          <path d="M4.5 4.5a3 3 0 0 0-3 3v9a3 3 0 0 0 3 3h8.25a3 3 0 0 0 3-3v-9a3 3 0 0 0-3-3H4.5ZM19.94 18.75l-2.69-2.69V7.94l2.69-2.69c.944-.945 2.56-.276 2.56 1.06v11.38c0 1.336-1.616 2.005-2.56 1.06Z" />
        </svg>
        <span>Stop Video</span>
      `

    console.log(`Camera ${enabled ? 'stopped' : 'started'}`)
  }

  leaveSession() {
    if (this.session) {
      this.session.disconnect()
    }
    window.location.href = '/'
  }


  sendMessage(event) {
    event.preventDefault()

    const messageText = this.chatInputTarget.value.trim()

    if (messageText && this.session) {
      const messageData = JSON.stringify({
        text: messageText,
        sender: this.userNameValue,
        timestamp: new Date().toISOString()
      })

      this.session.signal({
        type: 'chat',
        data: messageData
      }, (error) => {
        if (error) {
          console.error('Error sending message:', error)
          this.showError('Failed to send message', 'warning')
        } else {
          this.chatInputTarget.value = ''
        }
      })
    }
  }

  displayChatMessage(data, isSelf = false) {
    const message = JSON.parse(data)
    const messageElement = document.createElement('div')
    messageElement.classList.add('chat-message')
    messageElement.classList.add(isSelf ? 'self' : 'other')

    const timestamp = new Date(message.timestamp).toLocaleTimeString([], {
      hour: '2-digit',
      minute: '2-digit'
    })

    messageElement.innerHTML = `
      <div class="message-header">
        <span class="sender-name">${isSelf ? 'You' : this.escapeHtml(message.sender)}</span>
        <span class="message-time">${timestamp}</span>
      </div>
      <div class="message-text">${this.escapeHtml(message.text)}</div>
    `

    this.chatMessagesTarget.appendChild(messageElement)
    this.chatMessagesTarget.scrollTop = this.chatMessagesTarget.scrollHeight
  }

  showError(message, type = 'error') {
    if (this.hasErrorMessageTarget) {
      this.errorMessageTarget.innerHTML = message
      this.errorMessageTarget.className = `error-banner ${type}`
      this.errorMessageTarget.style.display = 'block'
    }
    console.error(`[${type.toUpperCase()}]`, message)
  }

  clearError() {
    if (this.hasErrorMessageTarget) {
      this.errorMessageTarget.style.display = 'none'
    }
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  handleChatKeydown(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault()
      this.sendMessage(event)
    }
  }
}
