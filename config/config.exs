# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :what_could_it_cost,
  ecto_repos: [WhatCouldItCost.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :what_could_it_cost, WhatCouldItCostWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: WhatCouldItCostWeb.ErrorHTML, json: WhatCouldItCostWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: WhatCouldItCost.PubSub,
  live_view: [signing_salt: "IQKsV+SK"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :what_could_it_cost, WhatCouldItCost.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  what_could_it_cost: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  what_could_it_cost: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :crawly,
  concurrent_requests_per_domain: 2,
  closespider_timeout: 1,
  closespider_itemcount: 10000,
  middlewares: [
    Crawly.Middlewares.DomainFilter,
    Crawly.Middlewares.UniqueRequest,
    {Crawly.Middlewares.UserAgent, user_agents: ["Crawly Bot"]}
  ],
  pipelines: [
    {Crawly.Pipelines.Validate, fields: [:name]},
    {Crawly.Pipelines.DuplicatesFilter, item_id: :name},
    Crawly.Pipelines.JSONEncoder,
    {Crawly.Pipelines.WriteToFile, extension: "jl", folder: "priv/data"}
  ]

# Cognito uses a custom response content type that we want to treat as JSON
config :mime, :types, %{
  "application/x-amz-json-1.1" => ["json"]
}

config :mime, :extensions, %{
  "json" => "application/json"
}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
