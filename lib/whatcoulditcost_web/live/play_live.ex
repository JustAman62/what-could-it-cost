defmodule WhatCouldItCostWeb.PlayLive do
  use WhatCouldItCostWeb, :live_view

  def render(assigns) do
    ~H"""
    Round: <%= @index %>
    Seed: <%= inspect(@seed) %>
    Brand: <%= @product["brand"] %> <.button phx-click="submit_answer">+</.button>
    """
  end

  def mount(_params, _session, socket) do
    product_data =
      File.stream!(Path.join(:code.priv_dir(:whatcoulditcost), "data/product_data.jl"))
      |> Enum.map(fn x -> Jason.decode!(x) end)
      |> Enum.at(0)

    {:ok,
     assign(socket, %{
       :index => 0,
       :seed => {:exsss, [1 | 2]},
       :product => product_data,
       :score => 0
     })}
  end

  def handle_event("submit_answer", _params, socket) do
    # return error:
    # {:noreply, put_flash(socket, :error, "last member cannot leave organization")}

    all_data =
      File.stream!(Path.join(:code.priv_dir(:whatcoulditcost), "data/product_data.jl"))
      |> Enum.map(fn x -> Jason.decode!(x) end)

    :rand.seed(socket.assigns.seed)
    next_product_index = :rand.uniform(Enum.count(all_data))

    IO.inspect(next_product_index)

    product_data = Enum.at(all_data, next_product_index)

    socket = update(socket, :index, &(&1 + 1))
    socket = assign(socket, :product, product_data)
    socket = assign(socket, :seed, :rand.export_seed())

    {:noreply, socket}
  end
end
