/**
 * Address Autocomplete Controller
 *
 * Stimulus controller for handling address autocomplete functionality
 * using Google Places API. Provides real-time city suggestions,
 * keyboard navigation, and weather forecast integration.
 *
 * Targets:
 * - searchInput: Text input for address search
 * - clearButton: Button to clear search input
 * - suggestionsDropdown: Container for suggestion results
 *
 * Features:
 * - Debounced search (300ms delay)
 * - Keyboard navigation (arrows, enter, escape)
 * - Google Places API integration
 * - Toast notifications for user feedback
 * - Loading state management
 * - Rate limit handling
 *
 * Dependencies:
 * - Google Places API
 * - Rails request.js for AJAX calls
 * - Toastify for notifications
 *
 * Events Emitted:
 * - startSpinner: When loading begins
 * - stopSpinner: When loading ends
 */

import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"
import Toastify from 'toastify-js'

export default class extends Controller {
  static targets = ["searchInput", "clearButton", "suggestionsDropdown"];

  connect() {
    this.setupEventListeners()
    this.selectedIndex = -1
    this.suggestions = []

    // Wait for Google API to load, then initialize
    this.waitForGoogleAPI()
  }

  waitForGoogleAPI() {
    if (typeof google !== "undefined" && google.maps && google.maps.places) {
      this.initGooglePlaces()
    } else {
      // Retry after a short delay
      setTimeout(() => this.waitForGoogleAPI(), 100)
    }
  }

  initGooglePlaces() {
    // Create autocomplete service
    this.autocompleteService = new google.maps.places.AutocompleteService()
    this.placesService = new google.maps.places.PlacesService(document.createElement("div"))
  }

  // Simple search function
  async search() {
    const query = this.searchInputTarget.value.trim()

    if (query.length === 0) {
      this.hideDropdown()
      return
    }

    // Use Google's AutocompleteService directly
    const request = {
      input: query,
      types: ["(cities)"],
      componentRestrictions: { country: "us" }
    }

    this.autocompleteService.getPlacePredictions(request, (predictions, status) => {
      if (status === google.maps.places.PlacesServiceStatus.OK && predictions) {
        this.showSuggestions(predictions)
      } else {
        this.hideDropdown()
      }
    })
  }

  showSuggestions(predictions) {
    this.suggestions = predictions

    if (predictions.length === 0) {
      this.hideDropdown()
      return
    }

    this.suggestionsDropdownTarget.innerHTML = predictions.map((prediction, index) => {
      // Safely escape the JSON string
      const safePrediction = JSON.stringify(prediction).replace(/"/g, '&quot;')

      // Extract city name and state/country from description
      const description = prediction.description
      const parts = description.split(', ')
      const cityName = parts[0]
      const location = parts.slice(1).join(', ')

      return `
      <button
        class="w-full px-4 py-3 text-left hover:bg-gray-50 transition-colors border-b border-gray-100 last:border-b-0 suggestion-item ${index === this.selectedIndex ? 'bg-blue-50' : ''}"
        data-prediction="${safePrediction}"
        data-action="click->components--address--autocomplete#selectSuggestion"
      >
        <div class="flex items-center gap-3">
          <svg class="h-4 w-4 text-gray-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
          </svg>
          <div>
            <div class="font-medium text-gray-900">${cityName}</div>
            <div class="text-sm text-gray-500">${location}</div>
          </div>
        </div>
      </button>
    `
    }).join('')

    this.suggestionsDropdownTarget.classList.remove('hidden')
    this.clearButtonTarget.classList.remove('hidden')
  }

  selectSuggestion(event) {
    const prediction = JSON.parse(event.currentTarget.dataset.prediction)

    // Get place details from Google Places Service
    const service = new google.maps.places.PlacesService(document.createElement('div'))
    const request = {
      placeId: prediction.place_id,
      fields: ['place_id', 'formatted_address', 'geometry', 'name']
    }

    service.getDetails(request, (place, status) => {
      if (status === google.maps.places.PlacesServiceStatus.OK && place) {
        this.selectAddress({
          place_id: place.place_id,
          description: place.formatted_address,
          coordinates: {
            lat: place.geometry.location.lat(),
            lng: place.geometry.location.lng()
          }
        })
      }
    })
  }

  selectAddress(address) {
    this.isLoading(true)

    this.searchInputTarget.value = address.description

    // Hide dropdown
    this.hideDropdown()
    this.searchInputTarget.blur()

    // Fetch forecast from backend
    this.fetchWeatherForecast(address)
  }

  async fetchWeatherForecast(address) {
    try {
      const response = await post('/forecasts', {
        responseKind: "turbo-stream",
        body: JSON.stringify({
          address: address.description,
          coordinates: address.coordinates
        })
      })
      if (response.ok) {
        this.showToast("Weather forecast retrieved successfully.")
        this.isLoading(false)
      } else {
        const body = await response
        const msg = body.statusCode === 429 ? "You’ve made too many requests in a short time. Please wait a few moments and try again." : "Could not fetch forecast, please try again or contact support."
        this.showToast(msg, "error")
        this.isLoading(false)
      }
    } catch (error) {
      console.log(error)
      this.showToast("Error updating weather fetching weather forecast, please try again or contact support.", "error")
      this.isLoading(false)
    }
  }

  hideDropdown() {
    this.suggestionsDropdownTarget.classList.add("hidden")
    this.clearButtonTarget.classList.add("hidden")
    this.selectedIndex = -1
  }

  clear() {
    this.searchInputTarget.value = ""
    this.hideDropdown()
    this.searchInputTarget.focus()
  }

  // Keyboard navigation
  handleKeydown(event) {
    if (!this.suggestionsDropdownTarget.classList.contains("hidden")) {
      switch (event.key) {
        case "ArrowDown":
          event.preventDefault()
          this.selectedIndex = Math.min(this.selectedIndex + 1, this.suggestions.length - 1)
          this.updateSelection()
          break
        case "ArrowUp":
          event.preventDefault()
          this.selectedIndex = Math.max(this.selectedIndex - 1, -1)
          this.updateSelection()
          break
        case "Enter":
          event.preventDefault()
          if (this.selectedIndex >= 0 && this.suggestions[this.selectedIndex]) {
            const prediction = this.suggestions[this.selectedIndex]
            const event = { currentTarget: { dataset: { prediction: JSON.stringify(prediction) } } }
            this.selectSuggestion(event)
          }
          break
        case "Escape":
          this.hideDropdown()
          this.searchInputTarget.blur()
          break
      }
    }
  }

  updateSelection() {
    const items = this.suggestionsDropdownTarget.querySelectorAll(".suggestion-item")
    items.forEach((item, index) => {
      item.classList.toggle("bg-blue-50", index === this.selectedIndex)
    })
  }

  setupEventListeners() {
    // Debounced search
    let searchTimeout
    this.searchInputTarget.addEventListener("input", () => {
      clearTimeout(searchTimeout)
      searchTimeout = setTimeout(() => this.search(), 300)
    })

    this.searchInputTarget.addEventListener("focus", () => {
      if (this.searchInputTarget.value.length > 0) {
        this.search()
      }
    })

    this.searchInputTarget.addEventListener("keydown", (e) => this.handleKeydown(e))

    // Clear button
    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.addEventListener("click", () => this.clear())
    }

    // Click outside to close
    document.addEventListener("click", (e) => {
      if (!this.element.contains(e.target)) {
        this.hideDropdown()
      }
    })
  }

  // Toast display method
  showToast(message, type= "success") {
    Toastify({
      text: message,
      duration: 3000,
      close: true,
      gravity: "top",
      position: "right",
      style: {
        background:
            type === "error"
                ? "linear-gradient(to right, #f44336, #f44336)"
                : "linear-gradient(to right, #4caf50, #4caf50)",
        borderRadius: "10px",
      },
      className:
          "max-w-sm w-full bg-white shadow-lg rounded-lg pointer-events-auto flex ring-1 ring-black ring-black/50 justify-between items-center p-4",
      stopOnFocus: true,
    }).showToast()
  }

  isLoading(spin = true) {
    spin
        ? document.dispatchEvent(new CustomEvent("startSpinner"))
        : document.dispatchEvent(new CustomEvent("stopSpinner"))
  }
}