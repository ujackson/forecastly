import { Application } from "@hotwired/stimulus"
import { createIcons, icons } from 'lucide';

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

createIcons({
	icons: icons,
	attrs: {'stroke-width': 2}
});

export { application }
