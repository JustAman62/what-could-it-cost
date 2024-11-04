defmodule WhatCouldItCostWeb.TelemetryController do
  @moduledoc """
  Exposes prometheus metrics
  """
  use WhatCouldItCostWeb, :controller
  alias Plug.Conn

  def metrics(conn, _params) do
    metrics = TelemetryMetricsPrometheus.Core.scrape()

    conn
    |> Conn.put_resp_content_type("text/plain")
    |> Conn.send_resp(200, metrics)
  end
end
