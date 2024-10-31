defmodule WhatCouldItCost.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WhatCouldItCostWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:whatcoulditcost, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: WhatCouldItCost.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: WhatCouldItCost.Finch},
      # Start a worker by calling: WhatCouldItCost.Worker.start_link(arg)
      # {WhatCouldItCost.Worker, arg},
      # Start to serve requests, typically the last entry
      WhatCouldItCostWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WhatCouldItCost.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WhatCouldItCostWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
