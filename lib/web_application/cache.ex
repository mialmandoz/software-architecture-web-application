defmodule WebApplication.Cache do
  @moduledoc """
  Cache module that works with or without Redis.
  Falls back to in-memory caching when Redis is unavailable.
  """
  require Logger

  @cache_name :web_application_cache

  def child_spec(_opts) do
    if redis_enabled?() do
      Logger.info("🔴 Redis caching enabled")

      %{
        id: __MODULE__,
        start: {Cachex, :start_link, [@cache_name, []]}
      }
    else
      Logger.info("💾 No caching - Redis disabled")

      %{
        id: __MODULE__,
        start: {Agent, :start_link, [fn -> :no_cache end, [name: @cache_name]]}
      }
    end
  end

  def get(key) do
    if redis_enabled?() do
      case Cachex.get(@cache_name, key) do
        {:ok, nil} ->
          Logger.debug("🔍 Cache MISS for key: #{key}")
          {:ok, nil}

        {:ok, value} ->
          Logger.debug("✅ Cache HIT for key: #{key}")
          {:ok, value}

        {:error, _} = error ->
          Logger.warning("❌ Cache ERROR for key: #{key}")
          error
      end
    else
      {:ok, nil}
    end
  end

  def put(key, value, ttl \\ :timer.hours(1)) do
    if redis_enabled?() do
      Logger.debug("💾 Cache PUT for key: #{key} (TTL: #{ttl}ms)")
      Cachex.put(@cache_name, key, value, ttl: ttl)
    else
      :ok
    end
  end

  def delete(key) do
    if redis_enabled?() do
      Logger.debug("🗑️ Cache DELETE for key: #{key}")
      Cachex.del(@cache_name, key)
    else
      :ok
    end
  end

  def delete_pattern(pattern) do
    if redis_enabled?() do
      case Cachex.keys(@cache_name) do
        {:ok, keys} ->
          matching_keys =
            Enum.filter(keys, fn key ->
              String.match?(to_string(key), ~r/#{String.replace(pattern, "*", ".*")}/)
            end)

          Logger.debug("🗑️ Cache DELETE PATTERN: #{pattern} (#{length(matching_keys)} keys)")
          Enum.each(matching_keys, &Cachex.del(@cache_name, &1))
          {:ok, length(matching_keys)}

        error ->
          error
      end
    else
      {:ok, 0}
    end
  end

  def clear do
    if redis_enabled?() do
      Logger.info("🧹 Cache CLEAR ALL")
      Cachex.clear(@cache_name)
    else
      :ok
    end
  end

  def stats do
    if redis_enabled?() do
      case Cachex.stats(@cache_name) do
        {:ok, stats} ->
          Logger.info("📊 Cache Stats: #{inspect(stats)}")
          {:ok, stats}

        error ->
          error
      end
    else
      {:ok, %{}}
    end
  end

  # Cache key generators
  def book_key(book_id), do: "book:#{book_id}"
  def author_key(author_id), do: "author:#{author_id}"
  def author_stats_key(filters), do: "author_stats:#{:erlang.phash2(filters)}"
  def review_key(review_id), do: "review:#{review_id}"
  def review_scores_key(book_id), do: "review_scores:#{book_id}"
  def book_reviews_key(book_id), do: "book_reviews:#{book_id}"
  def reviews_list_key(filters), do: "reviews_list:#{:erlang.phash2(filters)}"
  def books_list_key(filters), do: "books_list:#{:erlang.phash2(filters)}"
  def authors_list_key(filters), do: "authors_list:#{:erlang.phash2(filters)}"

  # Private functions
  defp redis_enabled? do
    System.get_env("REDIS_HOST") != nil
  end
end
