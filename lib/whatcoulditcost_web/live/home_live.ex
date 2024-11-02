defmodule WhatCouldItCostWeb.HomeLive do
  use WhatCouldItCostWeb, :live_view

  def render(assigns) do
    ~H"""
    <.flash_group flash={@flash} />
    <div class="flex flex-col h-svh bg-yellow-300 items-center justify-center text-center px-4">
      <h1 class="text-4xl font-bold">What Could It Cost?</h1>

      <p class="mt-16 font-semibold text-xl">
        Think you know how much your groceries cost?
      </p>
      <p class="mt-6 font-semibold text-xl">
        Play our "Name Your Price" style quiz below to find out!
      </p>

      <.form for={@form} phx-submit="start_seeded_game" class="flex flex-col items-stretch gap-2 mt-8">
        <.button phx-click="start_daily_game" class="mb-4">Play Daily</.button>

        <div>
          <.label>Seed</.label>
          <.input type="text" inputmode="numeric" pattern="[0-9]{4}" field={@form[:seed]} />
        </div>
        <.button type="submit">Play Seeded Game</.button>
      </.form>

      <p class="mt-8 text-sm">
        Use the same seed as your friends to play the same quiz
      </p>

      <div class="mt-8 flex flex-col items-center gap-2">
        <a
          href="https://github.com/JustAman62/what-could-it-cost"
          class="bg-slate-900 text-white hover:text-gray-200 py-1 px-2 rounded-lg inline-flex items-center gap-1"
        >
          <svg
            class="w-6 h-6"
            aria-hidden="true"
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            fill="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              fill-rule="evenodd"
              d="M12.006 2a9.847 9.847 0 0 0-6.484 2.44 10.32 10.32 0 0 0-3.393 6.17 10.48 10.48 0 0 0 1.317 6.955 10.045 10.045 0 0 0 5.4 4.418c.504.095.683-.223.683-.494 0-.245-.01-1.052-.014-1.908-2.78.62-3.366-1.21-3.366-1.21a2.711 2.711 0 0 0-1.11-1.5c-.907-.637.07-.621.07-.621.317.044.62.163.885.346.266.183.487.426.647.71.135.253.318.476.538.655a2.079 2.079 0 0 0 2.37.196c.045-.52.27-1.006.635-1.37-2.219-.259-4.554-1.138-4.554-5.07a4.022 4.022 0 0 1 1.031-2.75 3.77 3.77 0 0 1 .096-2.713s.839-.275 2.749 1.05a9.26 9.26 0 0 1 5.004 0c1.906-1.325 2.74-1.05 2.74-1.05.37.858.406 1.828.101 2.713a4.017 4.017 0 0 1 1.029 2.75c0 3.939-2.339 4.805-4.564 5.058a2.471 2.471 0 0 1 .679 1.897c0 1.372-.012 2.477-.012 2.814 0 .272.18.592.687.492a10.05 10.05 0 0 0 5.388-4.421 10.473 10.473 0 0 0 1.313-6.948 10.32 10.32 0 0 0-3.39-6.165A9.847 9.847 0 0 0 12.007 2Z"
              clip-rule="evenodd"
            />
          </svg>

          <span>GitHub</span>
        </a>

        <a
          href="https://amandhoot.com"
          class="bg-slate-900 text-white hover:text-gray-200 py-1 px-2 rounded-lg inline-flex items-center gap-1"
        >
          <svg
            class="w-6 h-6"
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
              d="M18 14v4.833A1.166 1.166 0 0 1 16.833 20H5.167A1.167 1.167 0 0 1 4 18.833V7.167A1.166 1.166 0 0 1 5.167 6h4.618m4.447-2H20v5.768m-7.889 2.121 7.778-7.778"
            />
          </svg>

          <span>More Games by Aman Dhoot</span>
        </a>

        <a href="https://ko-fi.com/C0C8XGTAR" target="_blank">
          <img
            class="h-8"
            src="https://storage.ko-fi.com/cdn/kofi6.png?v=6"
            alt="Buy Me a Coffee at ko-fi.com"
          />
        </a>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    # Random seed between 1000-9999
    seed = :rand.uniform(9000) + 1000
    form = %{"seed" => seed} |> to_form()

    {:ok, assign(socket, %{:form => form}), layout: false}
  end

  def handle_event("start_seeded_game", %{"seed" => seed}, socket) do
    {:noreply, redirect(socket, to: "/play/#{seed}")}
  end

  def handle_event("start_daily_game", _params, socket) do
    {:noreply, redirect(socket, to: "/play/daily")}
  end
end
