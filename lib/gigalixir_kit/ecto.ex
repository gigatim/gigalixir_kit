defmodule GigalixirKit.Ecto do
  @moduledoc """
  Provides helper functions to configure Ecto for Gigalixir deployments.

  Automatically detects tier (free vs. standard), handles SSL settings, and
  supports optional environment-based fallback for common config.
  """

  @spec config(keyword()) :: keyword()
  def config(opts \\ []) do
    url =
      Keyword.get(opts, :database_url) ||
        System.get_env("DATABASE_URL") ||
        raise """
        DATABASE_URL is missing.
        You can pass it directly via `database_url: ...` or define the DATABASE_URL env var.
        """

    pool_size =
      case Keyword.get(opts, :pool_size) || System.get_env("POOL_SIZE") do
        nil -> nil
        val when is_binary(val) -> String.to_integer(val)
        val -> val
      end

    tier = Keyword.get(opts, :tier, :auto)
    user_opts = Keyword.get(opts, :opts, [])

    tier = if tier == :auto, do: detect_tier(url), else: tier

    ssl_opts =
      case tier do
        :standard -> [verify: :verify_none, allowed_tls_versions: [:"tlsv1.2"]]
        :free -> [verify: :verify_none, cacerts: detect_cacerts()]
      end

    config =
      [
        url: url,
        ssl: true,
        ssl_opts: ssl_opts
      ]
      |> maybe_put(:pool_size, pool_size)
      |> Keyword.merge(user_opts)

    config
  end

  defp detect_cacerts do
    otp_major = :erlang.system_info(:otp_release) |> to_string() |> String.to_integer()

    if Code.ensure_loaded?(:public_key) and function_exported?(:public_key, :cacerts_get, 0) do
      :public_key.cacerts_get()
    else
      if otp_major >= 25 do
        raise """
        :public_key.cacerts_get/0 is expected to be available in OTP #{otp_major}, \
        but it is not. Ensure the :public_key application is correctly configured.
        """
      else
        []
      end
    end
  end

  defp detect_tier(url) do
    uri = URI.parse(url)
    host = uri.host || ""
    if String.contains?(host, "postgres-free-tier"), do: :free, else: :standard
  end

  defp maybe_put(config, _key, nil), do: config
  defp maybe_put(config, key, value), do: Keyword.put(config, key, value)
end
