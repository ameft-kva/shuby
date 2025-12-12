mount Jumpstart::Engine, at: "/jumpstart"
mount Mailbin::Engine, at: "/mailbin"

# Design System demo page
get "/design_system", to: "design_system#show"
