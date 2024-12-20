defmodule WhatCouldItCostWeb.PlayLive do
  use WhatCouldItCostWeb, :live_view

  defp render_waiting_for_answer(assigns) do
    ~H"""
    <p class="font-semibold text-lg mb-2" id="round-number" phx-hook="restoreGameResult">
      Round <%= @index + 1 %>/5
    </p>
    <img
      src={"https://trolley.co.uk/img/product/#{@product["product_id"]}"}
      class="h-52 md:h-64 w-52 md:w-64 rounded-xl shadow-lg p-4 bg-white"
    />
    <div class="my-4 flex flex-col items-center">
      <h1 class="text-2xl md:text-3xl font-semibold"><%= @product["brand"] %></h1>
      <h2 class="text-lg md:text-xl"><%= @product["name"] %></h2>
    </div>
    <.form for={@form} id="price-form" phx-submit="submit_answer" class="flex flex-col items-stretch">
      <.label for="price">Price</.label>
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
        <input
          name="price"
          id="price"
          type="number"
          inputmode="decimal"
          pattern="[0-9\.]+"
          step="0.01"
          max="1000.0"
          required
          value={@form[:price].value}
          autofocus
          phx-mounted={JS.focus()}
          class="mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 ps-10"
        />
      </div>
      <.button id="submit-price" type="submit" class="bg-brand flex">
        <svg
          class="w-6 h-6 text-white"
          aria-hidden="true"
          xmlns="http://www.w3.org/2000/svg"
          width="24"
          height="24"
          fill="none"
          viewBox="0 0 24 24"
        >
          <path
            stroke="currentColor"
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M19 12H5m14 0-4 4m4-4-4-4"
          />
        </svg>
        <span class="grow text-center">Submit</span>
      </.button>
    </.form>
    """
  end

  defp render_review_score(assigns) do
    assigns =
      assigns
      |> assign(product_price: Decimal.parse(assigns.product["price"]) |> elem(0))
      |> assign(prev_product_price: Decimal.parse(assigns.product["prev_price"]) |> elem(0))

    ~H"""
    <p class="font-semibold text-lg mb-2">Round <%= @index + 1 %>/5</p>
    <img
      src={"https://trolley.co.uk/img/product/#{@product["product_id"]}"}
      class="h-52 md:h-64 w-52 md:w-64 rounded-xl shadow-lg p-4 bg-white"
    />
    <div class="my-4 flex flex-col items-center">
      <h1 class="text-2xl md:text-3xl font-semibold"><%= @product["brand"] %></h1>
      <h2 class="text-lg md:text-xl"><%= @product["name"] %></h2>
    </div>

    <div class="w-64 md:w-96 bg-gray-200 flex rounded-full h-2.5">
      <div
        id="progress"
        class="bg-green-600 h-2.5 rounded-full"
        style={"max-width: #{(@last_score/1000) * 100}%"}
        phx-mounted={
          JS.transition({"transition-[width] ease-in-out duration-1000", "w-0", "w-[100%]"},
            time: 1000
          )
        }
      >
      </div>
    </div>

    <div class="flex w-64 md:w-96 mt-2">
      <div class="flex flex-col grow items-center text-center">
        <p class="font-semibold text-sm">Your Answer</p>
        <p class="font-bold text-xl">£<%= :erlang.float_to_binary(@last_answer, decimals: 2) %></p>
        <div class="h-4"></div>

        <p class="font-semibold text-sm mt-4">Round Score</p>
        <p class="font-bold text-xl"><%= @last_score %> / 1000</p>
      </div>
      <div class="flex flex-col grow items-center text-center">
        <p class="font-semibold text-sm">Actual</p>
        <p class="font-bold text-xl">
          £<%= :erlang.float_to_binary(String.to_float(@product["price"]), decimals: 2) %>
        </p>
        <%= case Decimal.compare(@product_price, @prev_product_price) do %>
          <% :lt -> %>
            <span class="text-[0.65rem] h-4 font-semibold text-green-600 flex items-center gap-1">
              <.icon name="hero-arrow-down-right" class="h-3 w-3" />
              <.product_change_change
                prev_product_price={@prev_product_price}
                product_price={@product_price}
              />
            </span>
          <% :gt -> %>
            <span class="text-[0.65rem] h-4 font-semibold text-red-600 flex items-center gap-1">
              <.icon name="hero-arrow-up-right" class="h-3 w-3" />
              <.product_change_change
                prev_product_price={@product_price}
                product_price={@prev_product_price}
              />
            </span>
          <% _ -> %>
            <div class="h-4"></div>
        <% end %>

        <p class="font-semibold text-sm mt-4">Total Score</p>
        <p class="font-bold text-xl"><%= @score %></p>
      </div>
    </div>

    <.button
      class="bg-brand mt-4 flex w-52"
      phx-click="next_round"
      phx-window-keydown="next_round"
      phx-key="Enter"
    >
      <svg
        class="w-6 h-6 text-white"
        aria-hidden="true"
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        fill="none"
        viewBox="0 0 24 24"
      >
        <path
          stroke="currentColor"
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M19 12H5m14 0-4 4m4-4-4-4"
        />
      </svg>
      <span class="grow text-center">Next</span>
    </.button>
    """
  end

  defp render_finished(assigns) do
    ~H"""
    <div class="w-64 md:w-96 bg-gray-200 flex rounded-full h-2.5 mt-4">
      <div
        id="progress"
        class="bg-green-600 h-2.5 rounded-full"
        style={"max-width: #{(@score/5000) * 100}%"}
        phx-mounted={
          JS.transition({"transition-[width] ease-in-out duration-1000", "w-0", "w-[100%]"},
            time: 1000
          )
        }
      >
      </div>
    </div>

    <p class="font-semibold text-sm mt-2">Your Score</p>
    <p class="font-bold text-xl"><%= @score %> / 5000</p>

    <div class="divide-y divide-black mt-2">
      <div :for={result <- @results} class="flex p-2 self-stretch gap-2">
        <.finished_product result={result} />
      </div>
    </div>

    <h2 class="font-semibold text-lg mt-4 mb-2">Share</h2>

    <div class="flex flex-col gap-2 text-white">
      <.copy_button id="copy-button" content={@results_text} />
      <.share_button id="share-button" content={@results_text} />
      <.button class="bg-brand mt-4 flex" phx-click="play_again">
        <svg
          class="w-6 h-6 text-white"
          aria-hidden="true"
          xmlns="http://www.w3.org/2000/svg"
          width="24"
          height="24"
          fill="none"
          viewBox="0 0 24 24"
        >
          <path
            stroke="currentColor"
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M13.484 9.166 15 7h5m0 0-3-3m3 3-3 3M4 17h4l1.577-2.253M4 7h4l7 10h5m0 0-3 3m3-3-3-3"
          />
        </svg>
        <span class="grow text-center">Play Random</span>
      </.button>

      <a href="https://ko-fi.com/C0C8XGTAR" target="_blank">
        <img
          class="w-32 mt-4 mx-auto"
          src="https://storage.ko-fi.com/cdn/kofi6.png?v=6"
          alt="Buy Me a Coffee at ko-fi.com"
        />
      </a>
    </div>
    """
  end

  attr :result, :map, required: true

  def finished_product(assigns) do
    assigns =
      assigns
      |> assign(product_price: Decimal.parse(assigns.result["product"]["price"]) |> elem(0))
      |> assign(
        prev_product_price: Decimal.parse(assigns.result["product"]["prev_price"]) |> elem(0)
      )

    ~H"""
    <img
      src={"https://trolley.co.uk/img/product/#{@result["product"]["product_id"]}"}
      class="h-14 w-14 rounded-lg shadow-lg p-1 bg-white self-center"
    />
    <div class="flex flex-col items-start justify-start text-left grow">
      <h1 class="text-md font-semibold"><%= @result["product"]["brand"] %></h1>
      <h2 class="text-xs"><%= @result["product"]["name"] %></h2>
      <%= case Decimal.compare(@product_price, @prev_product_price) do %>
        <% :lt -> %>
          <span class="text-[0.65rem] font-semibold text-green-600 flex items-center gap-1">
            <.icon name="hero-arrow-down-right" class="h-3 w-3" />
            <.product_change_change
              prev_product_price={@prev_product_price}
              product_price={@product_price}
            />
          </span>
        <% :gt -> %>
          <span class="text-[0.65rem] font-semibold text-red-600 flex items-center gap-1">
            <.icon name="hero-arrow-up-right" class="h-3 w-3" />
            <.product_change_change
              prev_product_price={@product_price}
              product_price={@prev_product_price}
            />
          </span>
        <% _ -> %>
          <span></span>
      <% end %>
    </div>
    <div class="flex flex-col items-center justify-center text-center flex-none w-12">
      <p class="font-semibold text-xs">You</p>
      <p class="font-bold text-md">
        £<%= :erlang.float_to_binary(@result["price"] * 1.0, decimals: 2) %>
      </p>
    </div>
    <div class="flex flex-col items-center justify-center text-center flex-none w-12">
      <p class="font-semibold text-xs">Actual</p>
      <p class="font-bold text-md">£<%= Decimal.to_string(@product_price) %></p>
    </div>
    """
  end

  attr :prev_product_price, :any, required: true
  attr :product_price, :any, required: true

  def product_change_change(assigns) do
    ~H"""
    <span>
      £<%= Decimal.sub(@prev_product_price, @product_price) |> Decimal.to_string() %> (<%= Decimal.div(
        @prev_product_price,
        @product_price
      )
      |> Decimal.sub(1)
      |> Decimal.mult(100)
      |> Decimal.round(0)
      |> Decimal.to_string() %>%)
      since Oct 2023
    </span>
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
    <div
      class="flex flex-col items-center md:ring-1 ring-black rounded-xl md:px-4 md:pt-2 md:pb-4 text-center"
      id="wrapper"
      phx-hook="saveGameResult"
    >
      <%= @inner %>
    </div>

    <%= if @initial_seed != "daily" do %>
      <div class="text-center mt-8">
        <p class="mt-2 text-xs">
          Your Random Seed: <span class="font-bold font-mono"><%= @initial_seed %></span>
        </p>
        <p class="text-xs">Share this seed with your friends to play the same quiz.</p>
      </div>
    <% end %>
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
    {type, initial_seed_val} =
      case initial_seed do
        "daily" -> {:daily, "#{Date.diff(NaiveDateTime.utc_now(), ~D[2024-10-01]) + 1000}"}
        _ -> {:seeded, initial_seed}
      end

    case Integer.parse(initial_seed_val) do
      {initial_seed_val, ""} when initial_seed_val >= 1000 and initial_seed_val < 10000 ->
        all_products =
          File.stream!(Path.join(:code.priv_dir(:whatcoulditcost), "data/product_data.jl"))
          |> Enum.map(fn x -> Jason.decode!(x) end)

        initial_product_index = rem(initial_seed_val, Enum.count(all_products))
        product_data = Enum.at(all_products, initial_product_index)

        # Mount is called twice, once on initial render, then once on ws connection
        # only record the metric on the second render (the live one)
        if connected?(socket) do
          :telemetry.execute([:wcic, :game, :started], %{count: 1}, %{type: type})
        end

        {:ok,
         assign(socket, %{
           :stage => :waiting_for_answer,
           :index => 0,
           :type => type,
           :initial_seed => initial_seed,
           :seed => {:exsss, [1 | initial_seed_val]},
           :product => product_data,
           :score => 0,
           :last_score => 0,
           :last_answer => 0.0,
           :form => %{"price" => ""} |> to_form(),
           :results => [],
           :results_text => """
           What Could It Cost?
           ##{initial_seed_val}
           """,
           :start_time => NaiveDateTime.utc_now()
         })}

      _ ->
        {:ok, assign(socket, %{:stage => :invalid_seed})}
    end
  end

  def handle_event("submit_answer", %{"price" => price}, socket) do
    socket = clear_flash(socket)

    # If the price starts with a decimal point, prepend a 0 to make float parsing work correctly
    price =
      case price do
        "." <> _ -> "0" <> price
        _ -> price
      end

    case Float.parse(price) do
      # Calculate the score for this round
      {price, ""} when price > 0 ->
        {product_price, ""} = Float.parse(socket.assigns.product["price"])

        # Score is zero when you are 25% or more away, or £2.50, whatever is the highest
        zero_score_mark = max(product_price * 0.25, 2.50)
        diff = abs(product_price - price)

        # If your are less far away from the real price than the zero score mark, then you score that % away out of 1000 max points
        round_score =
          if diff < zero_score_mark do
            round((1 - diff / zero_score_mark) * 1000)
          else
            0
          end

        socket =
          socket
          |> assign(:last_answer, price)
          |> assign(:last_score, round_score)
          |> update(:score, &(&1 + round_score))
          |> update(
            :results,
            &(&1 ++
                [%{"product" => socket.assigns.product, "score" => round_score, "price" => price}])
          )
          |> update(:results_text, &(&1 <> "#{emoji_progress_bar(round_score, 1000)}\n"))
          |> assign(:stage, :review_score)

        {:noreply, socket}

      _ ->
        {:noreply, put_flash(socket, :error, "Invalid price provided")}
    end
  end

  def handle_event("next_round", _params, socket) do
    case socket.assigns do
      %{index: index, stage: :review_score} when index < 4 ->
        # Determine the next product
        all_data =
          File.stream!(Path.join(:code.priv_dir(:whatcoulditcost), "data/product_data.jl"))
          |> Enum.map(fn x -> Jason.decode!(x) end)

        :rand.seed(socket.assigns.seed)
        next_product_index = :rand.uniform(Enum.count(all_data))

        product_data = Enum.at(all_data, next_product_index)

        socket =
          socket
          |> update(:index, &(&1 + 1))
          |> assign(:product, product_data)
          |> assign(:seed, :rand.export_seed())
          |> assign(:form, %{"price" => ""} |> to_form())
          |> assign(:stage, :waiting_for_answer)

        {:noreply, socket}

      %{index: index, stage: :review_score} when index == 4 ->
        results_text = """
        #{socket.assigns.results_text |> String.trim("\n")}
        Score: #{socket.assigns.score}/5000

        https://whatcoulditcost.amandhoot.com/play/#{socket.assigns.initial_seed}
        """

        socket =
          socket
          |> assign(:stage, :finished)
          |> assign(:results_text, results_text)

        socket =
          if socket.assigns.type == :daily do
            push_event(socket, "saveGameResult", %{
              results_text: socket.assigns.results_text,
              results: socket.assigns.results,
              score: socket.assigns.score,
              date: NaiveDateTime.utc_now()
            })
          else
            socket
          end

        duration = Time.diff(NaiveDateTime.utc_now(), socket.assigns.start_time)

        :telemetry.execute(
          [:wcic, :game, :ended],
          %{duration: duration},
          %{type: socket.assigns.type}
        )

        :telemetry.execute(
          [:wcic, :game, :ended],
          %{score: socket.assigns.score},
          %{type: socket.assigns.type}
        )

        {:noreply, socket}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("play_again", _params, socket) do
    seed = :rand.uniform(9000) + 1000
    {:noreply, redirect(socket, to: "/play/#{seed}")}
  end

  def handle_event(
        "restoreGameResult",
        %{"results_text" => results_text, "score" => score, "date" => date, "results" => results},
        socket
      ) do
    socket =
      if socket.assigns.type == :daily &&
           Date.diff(NaiveDateTime.utc_now(), NaiveDateTime.from_iso8601!(date)) == 0 do
        socket
        |> assign(:stage, :finished)
        |> assign(:score, score)
        |> assign(:results_text, results_text)
        |> assign(:results, results)
      else
        socket
      end

    {:noreply, socket}
  end

  defp emoji_progress_bar(score, total_score) do
    green = round(score / total_score * 5)
    red = 5 - green

    "#{String.duplicate("🟩", green)}#{String.duplicate("🟥", red)}"
  end
end
