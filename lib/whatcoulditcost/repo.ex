defmodule WhatCouldItCost.Repo do
  use Ecto.Repo,
    otp_app: :whatcoulditcost,
    adapter: Ecto.Adapters.SQLite3
end
