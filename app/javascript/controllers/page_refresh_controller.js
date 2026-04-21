import { Controller } from "@hotwired/stimulus"

// This controller triggers a Turbo page visit when connected to the DOM.
// Used by turbo_stream responses to reload the page after modal actions.
export default class extends Controller {
  connect() {
    Turbo.visit(window.location.href, { action: "replace" })
  }
}
