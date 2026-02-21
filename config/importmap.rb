# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@opentok/client", to: "@opentok--client.js" # @2.32.1
pin "process" # @2.1.0
pin "@rails/request.js", to: "https://ga.jspm.io/npm:@rails/request.js@0.0.13/src/index.js"
