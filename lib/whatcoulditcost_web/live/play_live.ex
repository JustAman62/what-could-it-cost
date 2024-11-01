defmodule WhatCouldItCostWeb.PlayLive do
  use WhatCouldItCostWeb, :live_view

  defp render_waiting_for_answer(assigns) do
    ~H"""
    <p class="font-semibold text-lg mb-2">Round <%= @index + 1 %>/5</p>
    <img src={@product["img"]} class="h-64 w-auto rounded-xl shadow-lg" />
    <div class="my-4 flex flex-col items-center">
      <h1 class="text-3xl font-semibold"><%= @product["brand"] %></h1>
      <h2 class="text-xl"><%= @product["name"] %></h2>
    </div>
    <.form for={@form} phx-submit="submit_answer" class="flex flex-col items-stretch gap-2">
      <div class="relative mb-6">
        <div class="absolute inset-y-0 start-0 flex items-center ps-2 pointer-events-none">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="w-7 h-7 text-gray-500 dark:text-gray-400 mt-2"
            aria-hidden="true"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M14.121 7.629A3 3 0 0 0 9.017 9.43c-.023.212-.002.425.028.636l.506 3.541a4.5 4.5 0 0 1-.43 2.65L9 16.5l1.539-.513a2.25 2.25 0 0 1 1.422 0l.655.218a2.25 2.25 0 0 0 1.718-.122L15 15.75M8.25 12H12m9 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
            />
          </svg>
        </div>
        <%!-- <.label for="price">Price</.label> --%>
        <input
          type="text"
          name="price"
          id="price"
          inputmode="numeric"
          pattern="[0-9]+(|\.[0-9]{2})"
          step="0.01"
          value={@form[:price].value}
          class="mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 ps-10"
        />
      </div>
      <.button type="submit" class="bg-brand">Submit</.button>
    </.form>
    """
  end

  defp render_review_score(assigns) do
    ~H"""
    <p class="font-semibold text-lg mb-2">Round <%= @index + 1 %>/5</p>
    <img src={@product["img"]} class="h-64 w-auto rounded-xl shadow-lg" />
    <div class="my-4 flex flex-col items-center">
      <h1 class="text-3xl font-semibold"><%= @product["brand"] %></h1>
      <h2 class="text-xl"><%= @product["name"] %></h2>
    </div>

    <div class="w-96 bg-gray-200 rounded-full h-2.5">
      <div class="bg-green-600 h-2.5 rounded-full" style={"width: #{(@last_score/1000) * 100}%"}></div>
    </div>

    <p class="font-semibold text-sm mt-4">Round Score</p>
    <p class="font-bold text-xl"><%= @last_score %> / 1000</p>

    <div class="flex w-96 mt-2">
      <div class="flex flex-col grow items-center text-center">
        <p class="font-semibold text-sm">Your Answer</p>
        <p class="font-bold text-xl">£<%= :erlang.float_to_binary(@last_answer, decimals: 2) %></p>
      </div>
      <div class="flex flex-col grow items-center text-center">
        <p class="font-semibold text-sm">Actual</p>
        <p class="font-bold text-xl">
          £<%= :erlang.float_to_binary(String.to_float(@product["price"]), decimals: 2) %>
        </p>
      </div>
    </div>

    <p class="font-semibold text-sm mt-4">Total Score</p>
    <p class="font-bold text-xl"><%= @score %></p>

    <.button class="bg-brand mt-4" phx-click="next_round">Next</.button>
    """
  end

  defp render_finished(assigns) do
    ~H"""
    <div class="w-96 bg-gray-200 rounded-full h-2.5 mt-4">
      <div class="bg-green-600 h-2.5 rounded-full" style={"width: #{@score/50}%"}></div>
    </div>

    <p class="font-semibold text-sm mt-4">Your Score</p>
    <p class="font-bold text-xl"><%= @score %> / 5000</p>

    <.button class="bg-brand mt-4" phx-click="play_again">Play Again</.button>
    """
  end

  defp render_invalid_seed(assigns) do
    ~H"""
    <div class="flex flex-col items-center text-center">
      <p class="font-semibold text-sm mt-4">
        The provided seed is invalid. It must be a number between 1000 and 9999.
      </p>

      <.button class="bg-brand mt-4" phx-click="play_again">Play with a Random Seed</.button>
    </div>
    """
  end

  defp render_wrapper(inner, assigns) do
    assigns = assign(assigns, :inner, inner)

    ~H"""
    <div class="flex flex-col items-center ring-1 ring-black rounded-xl px-4 pt-2 pb-4 text-center">
      <%= @inner %>
    </div>

    <div class="text-center mt-8">
      <p class="mt-2 text-xs">
        Your Random Seed: <span class="font-bold font-mono"><%= @initial_seed %></span>
      </p>
      <p class="text-xs">Share this seed with your friends to play the same quiz.</p>
    </div>
    """
  end

  def render(assigns) do
    case assigns.stage do
      :waiting_for_answer ->
        render_waiting_for_answer(assigns) |> render_wrapper(assigns)

      :review_score ->
        render_review_score(assigns) |> render_wrapper(assigns)

      :finished ->
        render_finished(assigns) |> render_wrapper(assigns)

      :invalid_seed ->
        render_invalid_seed(assigns)
    end
  end

  def mount(%{"initial_seed" => initial_seed}, _session, socket) do
    case Integer.parse(initial_seed) do
      {initial_seed, ""} when initial_seed >= 1000 and initial_seed < 10000 ->
        all_products =
          File.stream!(Path.join(:code.priv_dir(:whatcoulditcost), "data/product_data.jl"))
          |> Enum.map(fn x -> Jason.decode!(x) end)

        initial_product_index = rem(initial_seed, Enum.count(all_products))
        product_data = Enum.at(all_products, initial_product_index)

        {:ok,
         assign(socket, %{
           :stage => :waiting_for_answer,
           :index => 0,
           :initial_seed => initial_seed,
           :seed => {:exsss, [1 | initial_seed]},
           :product => product_data,
           :score => 0,
           :last_score => 0,
           :last_answer => 0.0,
           :form => %{"price" => ""} |> to_form()
         })}

      _ ->
        {:ok, assign(socket, %{:stage => :invalid_seed})}
    end
  end

  def handle_event("start_game", _params, socket) do
    {:noreply, assign(socket, :stage, :waiting_for_answer)}
  end

  def handle_event("submit_answer", %{"price" => price}, socket) do
    case Float.parse(price) do
      # Calculate the score for this round
      {price, ""} when price > 0 ->
        {product_price, ""} = Float.parse(socket.assigns.product["price"])

        diff = abs(product_price - price)
        # Score by giving max points (1000) for bang on, then remove 2 point per penny away
        # if you are more than £5 away, then you get 0 points
        score = round(max(0, 1000 - diff * 200))

        socket = assign(socket, :last_answer, price)
        socket = assign(socket, :last_score, score)
        socket = update(socket, :score, &(&1 + score))
        socket = assign(socket, :stage, :review_score)

        {:noreply, socket}

      _ ->
        {:noreply, put_flash(socket, :error, "Invalid price provided")}
    end
  end

  def handle_event("next_round", _params, socket) do
    if socket.assigns.index < 4 do
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
      socket = assign(socket, :form, %{"price" => ""} |> to_form())
      socket = assign(socket, :stage, :waiting_for_answer)

      {:noreply, socket}
    else
      socket = assign(socket, :stage, :finished)
      {:noreply, socket}
    end
  end

  def handle_event("play_again", _params, socket) do
    seed = :rand.uniform(9000) + 1000
    {:noreply, redirect(socket, to: "/play/#{seed}")}
  end
end
