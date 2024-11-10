defmodule WhatCouldItCostWeb.UserAuth do
  use WhatCouldItCostWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  @id_token "wcic_id_token"
  @refresh_token "wcic_refresh_token"

  def set_tokens(conn, id_token, refresh_token) do
    conn
    |> put_resp_cookie(@id_token, id_token,
      same_site: "Strict",
      # 30 day max_age
      max_age: 60 * 60 * 24 * 30,
      sign: true
    )
    |> put_resp_cookie(@refresh_token, refresh_token,
      same_site: "Strict",
      # 30 day max_age
      max_age: 60 * 60 * 24 * 30,
      sign: true
    )
    |> put_token_in_session(id_token, refresh_token)
  end

  @doc """
  Logs the user out.
  """
  def log_out_user(conn) do
    conn
    |> delete_resp_cookie(@id_token)
    |> delete_resp_cookie(@refresh_token)
    |> redirect(to: ~p"/")
  end

  @doc """
  Authenticates the user by looking into the session.
  """
  def fetch_current_user(conn, _opts) do
    {user_id_token, refresh_token, conn} = ensure_user_token(conn)

    {conn, user} =
      case user_id_token && validate_id_token(user_id_token) do
        {:ok, claims} ->
          {conn, parse_claims(claims)}

        {:err, :expired} ->
          case WhatCouldItCost.Cognito.refresh_token(refresh_token) do
            {:ok, id_token} ->
              case validate_id_token(id_token) do
                {:ok, claims} ->
                  {conn |> set_tokens(id_token, refresh_token), parse_claims(claims)}

                _ ->
                  {conn, nil}
              end

            _ ->
              {conn, nil}
          end

        _ ->
          {conn, nil}
      end

    assign(conn, :current_user, user)
  end

  defp ensure_user_token(conn) do
    case {get_session(conn, :user_id_token), get_session(conn, :user_refresh_token)} do
      {id_token, refresh_token} when id_token != nil and refresh_token != nil ->
        {id_token, refresh_token, conn}

      _ ->
        id_token =
          fetch_cookies(conn, signed: [@id_token])
          |> Map.from_struct()
          |> get_in([:cookies, @id_token])

        refresh_token =
          fetch_cookies(conn, signed: [@refresh_token])
          |> Map.from_struct()
          |> get_in([:cookies, @refresh_token])

        {id_token, refresh_token, put_token_in_session(conn, id_token, refresh_token)}
    end
  end

  @doc """
  Handles mounting and authenticating the current_user in LiveViews.

  ## `on_mount` arguments

    * `:mount_current_user` - Assigns current_user
      to socket assigns based on user_token, or nil if
      there's no user_token or no matching user.

    * `:ensure_authenticated` - Authenticates the user from the session,
      and assigns the current_user to socket assigns based
      on user_token.
      Redirects to login page if there's no logged user.

  ## Examples

  Use the `on_mount` lifecycle macro in LiveViews to mount or authenticate
  the current_user:

      defmodule WhatCouldItCostWeb.PageLive do
        use WhatCouldItCostWeb, :live_view

        on_mount {WhatCouldItCostWeb.UserAuth, :mount_current_user}
        ...
      end

  Or use the `live_session` of your router to invoke the on_mount callback:

      live_session :authenticated, on_mount: [{WhatCouldItCostWeb.UserAuth, :ensure_authenticated}] do
        live "/profile", ProfileLive, :index
      end
  """
  def on_mount(:mount_current_user, _params, session, socket) do
    {:cont, mount_current_user(socket, session)}
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You must log in to access this page.")
        |> Phoenix.LiveView.redirect(to: ~p"/login")

      {:halt, socket}
    end
  end

  defp mount_current_user(socket, session) do
    Phoenix.Component.assign_new(socket, :current_user, fn ->
      if id_token = session["user_id_token"] do
        case validate_id_token(id_token) do
          {:ok, claims} ->
            parse_claims(claims)

          _ ->
            nil
        end
      end
    end)
  end

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> maybe_store_return_to()
      |> redirect(to: ~p"/login")
      |> halt()
    end
  end

  defp put_token_in_session(conn, id_token, refresh_token) do
    conn
    |> put_session(:user_id_token, id_token)
    |> put_session(:user_refresh_token, refresh_token)
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :user_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  defp validate_id_token(id_token) do
    current_unix_time =
      DateTime.utc_now(:second) |> DateTime.to_unix()

    case WhatCouldItCost.CognitoToken.verify_and_validate(id_token) do
      {:ok, claims} ->
        if claims["exp"] > current_unix_time do
          {:ok, claims}
        else
          IO.inspect(current_unix_time, label: "Expired Token")
          {:err, :expired}
        end

      _ = val ->
        IO.inspect(val, label: "Invalid Token")
        {:err, :unknown}
    end
  end

  defp parse_claims(claims) do
    %{user_id: claims["sub"], username: claims["cognito:username"]}
  end
end
