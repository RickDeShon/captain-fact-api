defmodule CaptainFact.CORS do
  @frontend "http://localhost:3333"
  @chrome_extension "chrome-extension://ncoomilaknkmjmkeclinkmkjflkkeobh"

  use Corsica.Router,
    allow_headers: ~w(Accept Content-Type Authorization),
    max_age: 600

  # Allow frontend for regular API
  resource "/api/*", origins: @frontend

  # Allow certain paths for chrome extension
  resource "/extension_api/*", origins: @chrome_extension
end