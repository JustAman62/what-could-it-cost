defmodule WhatCouldItCost.Repo do
  use Ecto.Repo,
    otp_app: :what_could_it_cost,
    adapter: Ecto.Adapters.SQLite3
end
