# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "lucide", to: "https://unpkg.com/lucide@latest/dist/esm/lucide.js", preload: true
pin "toastify-js" # @1.12.0
pin "spin.js", preload: true # @4.1.2
