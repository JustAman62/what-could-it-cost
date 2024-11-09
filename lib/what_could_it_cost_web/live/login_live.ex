defmodule WhatCouldItCostWeb.LoginLive do
  use WhatCouldItCostWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center">
      <.form for={@form} id="price-form" action="/login" class="flex flex-col items-stretch gap-4">
        <div>
          <.label for="price">Username</.label>
          <.input
            name="username"
            id="username"
            type="text"
            autocomplete="username"
            required
            value={@form[:username].value}
          />
        </div>

        <div>
          <.label for="price">Password</.label>
          <.input
            name="password"
            id="password"
            type="password"
            autocomplete="current-password"
            required
            value={@form[:password].value}
          />
        </div>

        <.button id="login" type="submit" class="bg-brand flex">
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
          <span class="grow text-center">Login</span>
        </.button>
      </.form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    form = %{"username" => "", "password" => ""} |> to_form()

    {:ok, assign(socket, %{:form => form})}
  end
end
