defmodule WhatCouldItCostWeb.UserController do
  use WhatCouldItCostWeb, :controller
  alias WhatCouldItCost.Cognito

  def login(conn, %{"username" => username, "password" => password}) do
    conn = conn |> clear_flash()

    case Cognito.login(username, password) do
      {:ok, id_token, refresh_token} ->
        conn
        |> put_resp_cookie("wcic_id_token", id_token,
          same_site: "Strict",
          # 30 day max_age
          max_age: 60 * 60 * 24 * 30
          )
          |> put_resp_cookie("wcic_refresh_token", refresh_token,
          same_site: "Strict",
          # 30 day max_age
          max_age: 60 * 60 * 24 * 30
        )
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
