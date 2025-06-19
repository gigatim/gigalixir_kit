defmodule GigalixirKit.EctoTest do
  use ExUnit.Case, async: true
  alias GigalixirKit.Ecto

  setup do
    # Clean env before each test
    System.delete_env("DATABASE_URL")
    System.delete_env("POOL_SIZE")
    :ok
  end

  test "uses DATABASE_URL and POOL_SIZE from env when not passed" do
    System.put_env("DATABASE_URL", "ecto://user:pass@postgres-free-tier-abc.gigalixir.com/uuid-12345678-1234-5678-1234-567812345678")
    System.put_env("POOL_SIZE", "7")

    config = Ecto.config(skip_cert_check: true)
    assert config[:url] =~ "uuid-"
    assert config[:pool_size] == 7
    assert config[:ssl_opts][:cacertfile] != nil
  end

  test "raises if DATABASE_URL is missing and not passed" do
    assert_raise RuntimeError, fn ->
      Ecto.config()
    end
  end

  test "explicit values override env vars" do
    System.put_env("DATABASE_URL", "ecto://env_user:env_pass@env_host/env_db")
    config = Ecto.config(database_url: "ecto://user:pass@host/db", pool_size: 20)
    assert config[:url] == "ecto://user:pass@host/db"
    assert config[:pool_size] == 20
  end

  test "detects :free tier by UUID-style db name" do
    config = Ecto.config(
      database_url: "ecto://user:pass@postgres-free-tier-123.gigalixir.com/11111111-2222-3333-4444-555555555555",
      skip_cert_check: true
    )
    lssert config[:ssl_opts][:cacertfile] != nil
  end

  test "detects :standard tier by non-UUID db name" do
    config = Ecto.config(database_url: "ecto://user:pass@host/myapp_prod")
    assert config[:ssl_opts][:allowed_tls_versions] == [:"tlsv1.2"]
  end

  test "merges user opts into result" do
    config = Ecto.config(database_url: "ecto://user:pass@host/db", opts: [socket_options: [:inet6]])
    assert config[:socket_options] == [:inet6]
  end
end
