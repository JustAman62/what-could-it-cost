defmodule WhatCouldItCostWeb.UserController do
  use WhatCouldItCostWeb, :controller
  alias WhatCouldItCostWeb.UserAuth
  alias WhatCouldItCost.Cognito

  def login(conn, %{"username" => username, "password" => password}) do
    conn = conn |> clear_flash()

    case Cognito.login(username, password) do
      {:ok, id_token, refresh_token} ->
        conn
        |> UserAuth.set_tokens(id_token, refresh_token)
        |> redirect(to: "/")

      {:err, :user_not_confirmed} ->
        conn |> redirect(to: "/confirm-user?username=#{username}")

      {:err, _} ->
        conn
        |> put_flash(:error, "Incorrect username/password provided")
        |> redirect(to: "/login")
    end
  end
end
