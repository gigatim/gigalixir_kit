# GigalixirKit

**GigalixirKit** is a utility library for Elixir applications deployed on [Gigalixir](https://gigalixir.com).  
It provides drop-in runtime configuration helpers and deployment-aware conveniences.

## ✨ Features

- `GigalixirKit.Ecto.config/1` – automatically configures Ecto repo settings for free/standard Gigalixir databases

## 🚀 Usage

Include `gigalixir_kit` in your `mix.exs` dependencies:

```elixir
defp deps do
  [
    {:gigalixir_kit, "~> 0.1"}
  ]
end
```

Then run `mix deps.get` to install the dependency.

In your `config/runtime.exs`:

```elixir
import Config

config :my_app, MyApp.Repo, GigalixirKit.Ecto.config()

# or with your own ecto options
config :my_app, MyApp.Repo,
  GigalixirKit.Ecto.config(
    database_url: System.get_env("MY_DATABASE_URL"),
    opts: [
      socket_options: maybe_ipv6,
      pool_size: 20,
    ]
  )
```
