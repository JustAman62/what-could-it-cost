defmodule WhatCouldItCostWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000},
      # Add reporters as children of your supervision tree.
      # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
      {TelemetryMetricsPrometheus.Core, [metrics: metrics()]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix Metrics
      distribution("phoenix.endpoint.stop.duration",
        unit: {:native, :second},
        reporter_options: [
          buckets: [0.010, 0.025, 0.050, 0.100, 0.200, 0.500, 1.000]
        ]
      ),
      distribution("phoenix.router_dispatch.exception.duration",
        tags: [:route],
        unit: {:native, :second},
        reporter_options: [
          buckets: [0.010, 0.025, 0.050, 0.100, 0.200, 0.500, 1.000]
        ]
      ),
      distribution("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :second},
        reporter_options: [
          buckets: [0.010, 0.025, 0.050, 0.100, 0.200, 0.500, 1.000]
        ]
      ),
      distribution("phoenix.socket_connected.duration",
        unit: {:native, :second},
        reporter_options: [
          buckets: [0.010, 0.025, 0.050, 0.100, 0.200, 0.500, 1.000]
        ]
      ),

      # VM Metrics
      sum("vm.memory.total", unit: {:byte, :byte}, reporter_options: [prometheus_type: :gauge]),
      sum("vm.total_run_queue_lengths.total", reporter_options: [prometheus_type: :gauge]),
      sum("vm.total_run_queue_lengths.cpu", reporter_options: [prometheus_type: :gauge]),
      sum("vm.total_run_queue_lengths.io", reporter_options: [prometheus_type: :gauge]),

      # Custom game metrics
      sum("wcic.game.started.count",
        tags: [:type],
        prometheus_type: :counter
      ),
      distribution("wcic.game.ended.duration",
        tags: [:type],
        measurement: :duration,
        unit: :second,
        reporter_options: [
          buckets: [10, 25, 50, 100, 200, 500, 1000]
        ]
      ),
      distribution("wcic.game.ended.score",
        tags: [:type],
        reporter_options: [
          buckets: [1000, 2000, 3000, 4000, 5000]
        ]
      )
    ]
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      # {WhatCouldItCostWeb, :count_users, []}
    ]
  end
end
