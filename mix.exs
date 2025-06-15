defmodule GigalixirKit.MixProject do
  use Mix.Project

  def project do
    [
      app: :gigalixir_kit,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Runtime configuration helpers for Gigalixir deployments",
      package: [
        name: "gigalixir_kit",
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/yourusername/gigalixir_kit"}
      ]
    ]
  end

  def application, do: [extra_applications: [:logger, :ssl, :public_key]]

  defp deps, do: []
end
