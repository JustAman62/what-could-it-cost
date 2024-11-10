defmodule WhatCouldItCost.CognitoTokenStrategy do
  use JokenJwks.DefaultStrategyTemplate

  def init_opts(opts) do
    Keyword.merge(opts,
      jwks_url:
        "https://cognito-idp.eu-west-2.amazonaws.com/eu-west-2_t3F8AABCT/.well-known/jwks.json"
    )
  end
end

defmodule WhatCouldItCost.CognitoToken do
  use Joken.Config

  add_hook(JokenJwks, strategy: WhatCouldItCost.CognitoTokenStrategy)

  @impl true
  def token_config do
    %{}
    |> add_claim("aud", nil, &(&1 ==  "6q9id5vhqfocb9mc0deep4at49"))
  end
end
