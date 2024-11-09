defmodule WhatCouldItCost.Cognito do
  def login(username, password) do
    request_body = %{
      "AuthFlow" => "USER_PASSWORD_AUTH",
      "ClientId" => "6q9id5vhqfocb9mc0deep4at49",
      "AuthParameters" => %{
        "USERNAME" => username,
        "PASSWORD" => password
      }
    }

    req = new_req("AWSCognitoIdentityProviderService.InitiateAuth")

    {:ok, res} = Req.post(req, json: request_body)

    IO.inspect(res.body)

    case res do
      %{status: 400, body: %{"__type" => "UserNotConfirmedException"}} ->
        {:err, :user_not_confirmed}

      %{
        status: 200,
        body: %{
          "AuthenticationResult" => %{"IdToken" => id_token, "RefreshToken" => refresh_token}
        }
      } ->
        {:ok, id_token, refresh_token}

      _ ->
        IO.inspect(res)
        {:err, :unknown_error}
    end
  end

  defp new_req(target) do
    Req.new(base_url: "https://cognito-idp.eu-west-2.amazonaws.com/")
    |> Req.Request.put_header("content-type", "application/x-amz-json-1.1")
    |> Req.Request.put_header("x-amz-target", target)
  end
end
