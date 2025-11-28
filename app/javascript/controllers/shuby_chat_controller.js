import { Controller } from "@hotwired/stimulus"

// Controller for Shuby chat interface
// Handles scrolling, suggestions, and message input
export default class extends Controller {
    static targets = ["messages", "input"]
    static values = { chatId: Number }

    connect() {
        this.scrollToBottom()
        this.observeMessages()
    }

    disconnect() {
        if (this.observer) {
            this.observer.disconnect()
        }
    }

    // Observe new messages and scroll to bottom
    observeMessages() {
        const messagesContainer = document.getElementById("messages")
        if (!messagesContainer) return

        this.observer = new MutationObserver(() => {
            this.scrollToBottom()
        })

        this.observer.observe(messagesContainer, {
            childList: true,
            subtree: true
        })
    }

    // Scroll messages to the bottom
    scrollToBottom() {
        if (this.hasMessagesTarget) {
            this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
        }
    }

    // Insert a suggestion into the input field
    insertSuggestion(event) {
        const suggestion = event.currentTarget.dataset.suggestion
        if (this.hasInputTarget && suggestion) {
            this.inputTarget.value = suggestion
            this.inputTarget.focus()

            // Trigger auto-resize if available
            this.inputTarget.dispatchEvent(new Event("input"))

            // Remove welcome message when a suggestion is clicked
            const welcomeMessage = document.getElementById("welcome-message")
            if (welcomeMessage) {
                welcomeMessage.remove()
            }
        }
    }
}
