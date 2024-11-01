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

      <.form for={@form} phx-submit="start_game" class="flex flex-col items-stretch gap-2 mt-16">
        <div>
          <.label>Seed</.label>
          <.input type="text" inputmode="numeric" pattern="[0-9]{4}" field={@form[:seed]} />
        </div>
        <.button type="submit">Play</.button>
      </.form>

      <p class="mt-8 text-sm">
        Use the same seed as your friends to play the same quiz
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    # Random seed between 1000-9999
    seed = :rand.uniform(9000) + 1000
    form = %{"seed" => seed} |> to_form()

    {:ok, assign(socket, %{:form => form}), layout: false}
  end

  def handle_event("start_game", %{"seed" => seed}, socket) do
    {:noreply, redirect(socket, to: "/play/#{seed}")}
  end
end
