defmodule GigalixirKit.Ecto do
  @moduledoc """
  Provides helper functions to configure Ecto for Gigalixir deployments.
  """

  @spec config(keyword()) :: keyword()
  def config(opts \\ []) do
    opts = normalize_opts(opts)
    user_opts = Keyword.get(opts, :opts, [])

    [
      url: Keyword.fetch!(opts, :database_url),
      ssl: ssl_opts(opts)
    ]
    |> maybe_put(:pool_size, pool_size(opts))
    |> Keyword.merge(user_opts)
  end

  defp normalize_opts(opts) do
    url = Keyword.get(opts, :database_url) || get_url_from_env()
    host = URI.parse(url).host || ""
    tier = detect_tier(host)

    opts
    |> Keyword.put(:database_url, url)
    |> Keyword.put(:host, host)
    |> Keyword.put(:tier, tier)
  end

  defp get_url_from_env do
    System.get_env("DATABASE_URL") ||
      raise "DATABASE_URL is missing. Pass it in opts or set the env var."
  end

  defp pool_size(opts) do
    case Keyword.get(opts, :pool_size) || System.get_env("POOL_SIZE") do
      nil -> nil
      val when is_binary(val) -> String.to_integer(val)
      val -> val
    end
  end

  defp maybe_put(config, _key, nil), do: config
  defp maybe_put(config, key, val), do: Keyword.put(config, key, val)

  defp detect_tier(host) do
    if String.contains?(host, "postgres-free-tier"), do: :free, else: :standard
  end

  defp ssl_opts(opts) do
    tier = Keyword.fetch!(opts, :tier)

    case tier do
      :standard ->
        [verify: :verify_none, allowed_tls_versions: [:"tlsv1.2"]]

      :free ->
        host = Keyword.fetch!(opts, :host)
        path = "/opt/gigalixir/certs/#{host}.pem"

        unless Keyword.get(opts, :skip_cert_check) do
          unless File.exists?(path) do
            raise "Expected CA cert for #{host} at #{path}, but it does not exist"
          end
        end

        [
          cacertfile: path,
          hostname: String.to_charlist(host),
          server_name_indication: String.to_charlist(host),
          verify: :verify_none,
        ]
    end
  end
end
