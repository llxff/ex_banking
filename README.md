# ExBanking

[![Build Status](https://travis-ci.org/llxff/ex_banking?branch=develop)](https://travis-ci.org/llxff/ex_banking)

Task [https://github.com/heathmont/elixir-test](https://github.com/heathmont/elixir-test)

## Setup

In your `mix.exs` file:

```elixir
def deps do
  [
    {:ex_banking, github: "llxff/ex_banking", branch: "develop"}
  ]
end
```

You can setup operations limit in `config.exs`:

```elixir
use Mix.Config

config :ex_banking, :account, rate_limit: 10
```
