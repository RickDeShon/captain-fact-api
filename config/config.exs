# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :captain_fact, ecto_repos: [CaptainFact.Repo]

# Configures the endpoint
config :captain_fact, CaptainFact.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "avLUvr7bCD8k3H+fX+PQi7DvB7qocJBMmX4H05kdSYX3sHEmnsgalWU1RbpwP1Bh",
  render_errors: [view: CaptainFact.ErrorView, accepts: ~w(json), default_format: "json"],
  pubsub: [name: CaptainFact.PubSub, adapter: Phoenix.PubSub.PG2],
  force_ssl: [rewrite_on: [:x_forwarded_proto]]

config :captain_fact, send_in_blue_api_key: "wSh1X2D0U4zvjgGQ"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure ueberauth
config :ueberauth, Ueberauth,
base_path: "/api/auth",
providers: [
  identity: {
    Ueberauth.Strategy.Identity, [callback_methods: ["POST"]]
  }
]

# Configure Guardian (authentication)
config :guardian, Guardian,
  issuer: "CaptainFact",
  ttl: {30, :days},
  secret_key: "Qf+lilDob+feItWrI+b/Ls3gBglt8IFlnC+DoJIn1Bqvy3yy/oVRDGdlte4wTu/x",
  serializer: CaptainFact.GuardianSerializer,
  permissions: %{default: [:read, :write]}

# Configure ex_admin (Admin platform)
config :ex_admin,
  theme: ExAdmin.Theme.ActiveAdmin,
  repo: CaptainFact.Repo,
  module: CaptainFact,
  modules: [
    CaptainFact.ExAdmin.Dashboard,
    CaptainFact.ExAdmin.Speaker,
    CaptainFact.ExAdmin.Comment,
    CaptainFact.ExAdmin.User,
    CaptainFact.ExAdmin.Video
  ]

# Configure file upload
config :arc,
  storage: Arc.Storage.Local

# Configure scheduler
config :quantum, :captain_fact,
  cron: [
    # Reset score limit counter every midnight
    "@daily": fn -> CaptainFact.ReputationUpdater.reset() end
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :xain, :after_callback, {Phoenix.HTML, :raw}
