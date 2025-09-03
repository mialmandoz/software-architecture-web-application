defmodule WebApplication.Search do
  @moduledoc """
  OpenSearch integration for full-text search functionality.
  Automatically falls back to database search when OpenSearch is unavailable.
  """

  require Logger

  @opensearch_host System.get_env("OPENSEARCH_HOST", "localhost")
  @opensearch_port System.get_env("OPENSEARCH_PORT", "9200")
  @base_url "http://#{@opensearch_host}:#{@opensearch_port}"

  # Index names
  @books_index "books"
  @reviews_index "reviews"

  # Cache availability check for 30 seconds to avoid repeated network calls
  @availability_cache_ttl 30_000

  ## Public API

  @doc """
  Check if OpenSearch is available for UI conditional rendering.
  Uses a simple environment variable check for performance.
  """
  def available?() do
    # Simple check: if OPENSEARCH_HOST is set, assume OpenSearch should be available
    System.get_env("OPENSEARCH_HOST") != nil
  end

  @doc """
  Search books by title, summary, or author name with OpenSearch or fallback to database.
  Returns paginated results.
  """
  def search_books(query, opts \\ []) do
    _page = Keyword.get(opts, :page, 1)
    _per_page = Keyword.get(opts, :per_page, 10)

    if opensearch_available?() do
      opensearch_search_books(query, opts)
    else
      database_search_books(query, opts)
    end
  end

  @doc """
  Search reviews by content with OpenSearch or fallback to database.
  """
  def search_reviews(query, opts \\ []) do
    if opensearch_available?() do
      opensearch_search_reviews(query, opts)
    else
      database_search_reviews(query, opts)
    end
  end

  @doc """
  Index a book in OpenSearch. Safe to call even when OpenSearch is unavailable.
  """
  def index_book(book) do
    if opensearch_available?() and not seeding_mode?() do
      book_doc = %{
        id: book.id,
        title: book.name,
        summary: book.summary,
        author_name: book.author.name,
        author_id: book.author_id,
        inserted_at: book.inserted_at,
        updated_at: book.updated_at
      }

      case Req.put("#{@base_url}/#{@books_index}/_doc/#{book.id}", json: book_doc) do
        {:ok, %{status: status}} when status in [200, 201] ->
          Logger.debug("Indexed book #{book.id} in OpenSearch")
          :ok

        {:error, reason} ->
          Logger.warning("Failed to index book #{book.id}: #{inspect(reason)}")
          :error
      end
    else
      :ok
    end
  end

  @doc """
  Index a review in OpenSearch. Safe to call even when OpenSearch is unavailable.
  """
  def index_review(review) do
    if opensearch_available?() and not seeding_mode?() do
      review_doc = %{
        id: review.id,
        content: review.review,
        rating: review.score,
        book_id: review.book_id,
        book_title: review.book.name,
        author_name: review.book.author.name,
        inserted_at: review.inserted_at,
        updated_at: review.updated_at
      }

      case Req.put("#{@base_url}/#{@reviews_index}/_doc/#{review.id}", json: review_doc) do
        {:ok, %{status: status}} when status in [200, 201] ->
          Logger.debug("Indexed review #{review.id} in OpenSearch")
          :ok

        {:error, reason} ->
          Logger.warning("Failed to index review #{review.id}: #{inspect(reason)}")
          :error
      end
    else
      :ok
    end
  end

  @doc """
  Remove a book from OpenSearch index. Safe to call even when OpenSearch is unavailable.
  """
  def remove_book(book_id) do
    if opensearch_available?() and not seeding_mode?() do
      case Req.delete("#{@base_url}/#{@books_index}/_doc/#{book_id}") do
        {:ok, %{status: status}} when status in [200, 404] ->
          Logger.debug("Removed book #{book_id} from OpenSearch")
          :ok

        {:error, reason} ->
          Logger.warning("Failed to remove book #{book_id}: #{inspect(reason)}")
          :error
      end
    else
      :ok
    end
  end

  @doc """
  Remove a review from OpenSearch index. Safe to call even when OpenSearch is unavailable.
  """
  def remove_review(review_id) do
    if opensearch_available?() and not seeding_mode?() do
      case Req.delete("#{@base_url}/#{@reviews_index}/_doc/#{review_id}") do
        {:ok, %{status: status}} when status in [200, 404] ->
          Logger.debug("Removed review #{review_id} from OpenSearch")
          :ok

        {:error, reason} ->
          Logger.warning("Failed to remove review #{review_id}: #{inspect(reason)}")
          :error
      end
    else
      :ok
    end
  end

  ## Private Functions

  defp opensearch_available? do
    # Check if we have a cached result that's still valid
    case Process.get(:opensearch_availability_cache) do
      {result, timestamp} when is_boolean(result) ->
        if System.system_time(:millisecond) - timestamp < @availability_cache_ttl do
          result
        else
          check_and_cache_availability()
        end

      _ ->
        check_and_cache_availability()
    end
  end

  defp check_and_cache_availability do
    # Use a very short timeout and disable retries to fail fast
    result =
      case Req.get("#{@base_url}/_cluster/health",
             receive_timeout: 200,
             retry: false
           ) do
        {:ok, %{status: 200}} -> true
        _ -> false
      end

    # Cache the result with timestamp
    Process.put(:opensearch_availability_cache, {result, System.system_time(:millisecond)})
    result
  end

  defp seeding_mode? do
    System.get_env("SEEDING_MODE") == "true"
  end

  defp opensearch_search_books(query, opts) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 10)
    size = per_page
    from = (page - 1) * per_page

    search_body = %{
      query: %{
        multi_match: %{
          query: query,
          fields: ["title^2", "summary", "author_name^1.5"],
          type: "best_fields",
          fuzziness: 1
        }
      },
      size: size,
      from: from,
      sort: ["_score"]
    }

    case Req.post("#{@base_url}/#{@books_index}/_search", json: search_body) do
      {:ok, %{status: 200, body: %{"hits" => %{"hits" => hits, "total" => %{"value" => total}}}}} ->
        book_ids = Enum.map(hits, fn hit -> hit["_source"]["id"] end)

        pagination = %{
          page_number: page,
          page_size: per_page,
          total_entries: total,
          total_pages: ceil(total / per_page)
        }

        {:ok, book_ids, pagination}

      {:error, reason} ->
        Logger.warning("OpenSearch books search failed: #{inspect(reason)}")
        database_search_books(query, opts)
    end
  end

  defp opensearch_search_reviews(query, opts) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 10)
    size = per_page
    from = (page - 1) * per_page

    search_body = %{
      query: %{
        multi_match: %{
          query: query,
          fields: ["content^2", "book_title", "author_name"],
          type: "best_fields",
          fuzziness: 1
        }
      },
      size: size,
      from: from,
      sort: ["_score"]
    }

    case Req.post("#{@base_url}/#{@reviews_index}/_search", json: search_body) do
      {:ok, %{status: 200, body: %{"hits" => %{"hits" => hits, "total" => %{"value" => total}}}}} ->
        review_ids = Enum.map(hits, fn hit -> hit["_source"]["id"] end)

        pagination = %{
          page_number: page,
          page_size: per_page,
          total_entries: total,
          total_pages: ceil(total / per_page)
        }

        {:ok, review_ids, pagination}

      {:error, reason} ->
        Logger.warning("OpenSearch reviews search failed: #{inspect(reason)}")
        database_search_reviews(query, opts)
    end
  end

  defp database_search_books(query, opts) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 10)
    offset = (page - 1) * per_page

    import Ecto.Query
    alias WebApplication.Repo
    alias WebApplication.Books.Book

    # Get total count for pagination
    total_query =
      from(b in Book,
        join: a in assoc(b, :author),
        where:
          ilike(b.name, ^"%#{query}%") or
            ilike(b.summary, ^"%#{query}%") or
            ilike(a.name, ^"%#{query}%"),
        select: count(b.id)
      )

    total = Repo.one(total_query)

    books =
      from(b in Book,
        join: a in assoc(b, :author),
        where:
          ilike(b.name, ^"%#{query}%") or
            ilike(b.summary, ^"%#{query}%") or
            ilike(a.name, ^"%#{query}%"),
        select: b.id,
        offset: ^offset,
        limit: ^per_page
      )
      |> Repo.all()

    pagination = %{
      page_number: page,
      page_size: per_page,
      total_entries: total,
      total_pages: ceil(total / per_page)
    }

    {:ok, books, pagination}
  end

  defp database_search_reviews(query, _opts) do
    import Ecto.Query
    alias WebApplication.Repo
    alias WebApplication.Reviews.Review

    reviews =
      from(r in Review,
        where: ilike(r.review, ^"%#{query}%"),
        select: r.id,
        limit: 20
      )
      |> Repo.all()

    {:ok, reviews}
  end
end
