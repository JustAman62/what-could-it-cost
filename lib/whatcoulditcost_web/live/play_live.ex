defmodule WhatCouldItCostWeb.PlayLive do
  use WhatCouldItCostWeb, :live_view

  defp render_start_game(assigns) do
    ~H"""
    Click to begin:
    <.button phx-click="start_game">Start Game</.button>
    """
  end

  defp render_waiting_for_answer(assigns) do
    ~H"""
    <div class="flex flex-col items-center">
      <img src={@product["img"]} class="h-64 w-auto ring-2 ring-slate-300 shadow-lg rounded-lg p-4" />
      <div class="my-4 flex flex-col items-center">
        <h1 class="text-3xl font-semibold"><%= @product["brand"] %></h1>
        <h2 class="text-xl"><%= @product["name"] %></h2>
      </div>
      <.form for={@form} phx-submit="submit_answer" class="flex flex-col items-stretch gap-2">
        <.input type="text" inputmode="numeric" pattern="[0-9\.]*" field={@form[:price]} />
        <.button type="submit" class="bg-brand">Submit</.button>
      </.form>
    </div>
    Round: <%= @index %> Seed: <%= inspect(@seed) %> Brand: <%= @product["brand"] %>
    """
  end

  defp render_review_score(assigns) do
    ~H"""
    <div class="flex flex-col items-center">
      <img src={@product["img"]} class="h-64 w-auto ring-2 ring-slate-300 shadow-lg rounded-lg p-4" />
      <div class="my-4 flex flex-col items-center">
        <h1 class="text-3xl font-semibold"><%= @product["brand"] %></h1>
        <h2 class="text-xl"><%= @product["name"] %></h2>
      </div>
      <span>Your Answer: <%= @last_answer %></span>
      <span>Actual: <%= @product["price"] %></span>
      <span>Score: <%= @last_score %></span>
      <span>Total: <%= @score %></span>

      <.button class="bg-brand" phx-click="next_round">Next</.button>
    </div>
    """
  end

  def render(assigns) do
    inner =
      case assigns.stage do
        :start ->
          render_start_game(assigns)

        :waiting_for_answer ->
          render_waiting_for_answer(assigns)

        :review_score ->
          render_review_score(assigns)
      end

    assigns = assign(assigns, :inner, inner)

    ~H"""
    <div>
      <%= @inner %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    product_data =
      File.stream!(Path.join(:code.priv_dir(:whatcoulditcost), "data/product_data.jl"))
      |> Enum.map(fn x -> Jason.decode!(x) end)
      |> Enum.at(0)

    {:ok,
     assign(socket, %{
       :stage => :waiting_for_answer,
       :index => 0,
       :seed => {:exsss, [1 | 2]},
       :product => product_data,
       :score => 0,
       :last_score => 0,
       :form => %{"price" => 0} |> to_form()
     })}
  end

  def handle_event("start_game", _params, socket) do
    {:noreply, assign(socket, :stage, :waiting_for_answer)}
  end

  def handle_event("submit_answer", %{"price" => price}, socket) do
    {price, ""} = Float.parse(price)

    if price <= 0 do
      {:noreply, put_flash(socket, :error, "Invalid price provided")}
    else
      # Calculate the score for this round
      {product_price, ""} = Float.parse(socket.assigns.product["price"])

      diff = abs(product_price - price)
      # Score by giving max points (1000) for bang on, then remove 1 point per penny away
      # if you are more than £10 away, then you get 0 points
      score = max(0, 1000 - (diff * 100))

      socket = assign(socket, :last_answer, price)
      socket = assign(socket, :last_score, score)
      socket = update(socket, :score, &(&1 + score))
      socket = assign(socket, :stage, :review_score)

      {:noreply, socket}
    end
  end

  def handle_event("next_round", _params, socket) do
    # Determine the next product
    all_data =
      File.stream!(Path.join(:code.priv_dir(:whatcoulditcost), "data/product_data.jl"))
      |> Enum.map(fn x -> Jason.decode!(x) end)

    :rand.seed(socket.assigns.seed)
    next_product_index = :rand.uniform(Enum.count(all_data))

    product_data = Enum.at(all_data, next_product_index)

    socket = update(socket, :index, &(&1 + 1))
    socket = assign(socket, :product, product_data)
    socket = assign(socket, :seed, :rand.export_seed())
    socket = assign(socket, :form, %{"price" => 0} |> to_form())
    socket = assign(socket, :stage, :waiting_for_answer)

    {:noreply, socket}
  end
end
