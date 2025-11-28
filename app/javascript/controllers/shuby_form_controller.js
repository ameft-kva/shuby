import { Controller } from "@hotwired/stimulus"

// Controller for Shuby chat form
// Handles form submission, auto-resize, and keyboard shortcuts for streaming chat
export default class extends Controller {
    static targets = ["input", "submit"]

    connect() {
        this.autoResize()
        // Listen for turbo:submit-end to reset form after streaming starts
        this.element.addEventListener("turbo:submit-end", this.onSubmitEnd.bind(this))
    }

    disconnect() {
        this.element.removeEventListener("turbo:submit-end", this.onSubmitEnd.bind(this))
    }

    // Handle form submission - validate and disable button
    submit(event) {
        const message = this.inputTarget.value.trim()
        if (!message) {
            event.preventDefault()
            return
        }

        // Disable button while submitting
        if (this.hasSubmitTarget) {
            this.submitTarget.disabled = true
        }
    }

    // Called after Turbo processes the form submission
    onSubmitEnd(event) {
        // Clear input immediately after submission
        this.inputTarget.value = ""
        this.autoResize()

        // Re-enable button (it will be in the replaced form partial)
        if (this.hasSubmitTarget) {
            this.submitTarget.disabled = false
        }
    }

    // Handle Enter key to submit (Shift+Enter for new line)
    handleKeydown(event) {
        if (event.key === "Enter" && !event.shiftKey) {
            event.preventDefault()
            const form = this.element.closest("form") || this.element
            if (form.requestSubmit) {
                form.requestSubmit()
            } else {
                form.submit()
            }
        }
    }

    // Auto-resize textarea based on content
    autoResize() {
        if (!this.hasInputTarget) return

        const input = this.inputTarget
        input.style.height = "auto"
        input.style.height = Math.min(input.scrollHeight, 200) + "px"
    }
}
