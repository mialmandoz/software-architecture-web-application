defmodule WebApplication.Reviews do
  @moduledoc """
  The Reviews context.
  """

  import Ecto.Query, warn: false
  alias WebApplication.Repo
  alias WebApplication.Cache
  alias WebApplication.Search

  alias WebApplication.Reviews.Review

  @doc """
  Returns the list of reviews with pagination and optional filters.

  ## Examples

      iex> list_reviews()
      %Scrivener.Page{entries: [%Review{}, ...]}

  """
  def list_reviews(params \\ %{}) do
    filter_book = Map.get(params, "filter_book", "")
    page = String.to_integer(Map.get(params, "page", "1"))

    query =
      from(r in Review,
        join: b in assoc(r, :book),
        join: a in assoc(b, :author),
        preload: [book: {b, :author}],
        order_by: [desc: r.inserted_at]
      )

    query =
      if filter_book != "" do
        from([r, b, a] in query, where: ilike(b.name, ^"%#{filter_book}%"))
      else
        query
      end

    Repo.paginate(query, page: page, page_size: 10)
  end

  @doc """
  Search reviews by content with OpenSearch or fallback to database.
  Returns paginated results.

  ## Examples

      iex> search_reviews("great book")
      {[%Review{}, ...], %{page_number: 1, page_size: 10, total_entries: 5, total_pages: 1}}

  """
  def search_reviews(query, opts \\ []) when is_binary(query) and query != "" do
    case Search.search_reviews(query, opts) do
      {:ok, review_ids, pagination} when is_list(review_ids) and length(review_ids) > 0 ->
        # Get full review records in the order returned by search
        reviews =
          from(r in Review,
            join: b in assoc(r, :book),
            join: a in assoc(b, :author),
            where: r.id in ^review_ids,
            preload: [book: {b, :author}]
          )
          |> Repo.all()
          |> Enum.sort_by(&Enum.find_index(review_ids, fn id -> id == &1.id end))

        {reviews, pagination}

      {:ok, [], pagination} ->
        {[], pagination}

      _ ->
        {[], %{page_number: 1, page_size: 10, total_entries: 0, total_pages: 0}}
    end
  end

  @doc """
  Gets a single review.

  Raises `Ecto.NoResultsError` if the Review does not exist.

  ## Examples

      iex> get_review!(123)
      %Review{}

      iex> get_review!(456)
      ** (Ecto.NoResultsError)

  """
  def get_review!(id) do
    Repo.get!(Review, id)
    |> Repo.preload(:book)
  end

  @doc """
  Creates a review.

  ## Examples

      iex> create_review(%{field: value})
      {:ok, %Review{}}

      iex> create_review(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_review(attrs \\ %{}) do
    case %Review{}
         |> Review.changeset(attrs)
         |> Repo.insert() do
      {:ok, review} = result ->
        # Load book and author associations for indexing
        review_with_book = Repo.preload(review, book: :author)

        # Index in OpenSearch
        Search.index_review(review_with_book)

        # Invalidate related caches
        Cache.delete_pattern("reviews_list:*")
        Cache.delete_pattern("review_scores:#{review.book_id}")
        Cache.delete_pattern("book_reviews:#{review.book_id}")
        result

      error ->
        error
    end
  end

  @doc """
  Updates a review.

  ## Examples

      iex> update_review(review, %{field: new_value})
      {:ok, %Review{}}

      iex> update_review(review, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_review(%Review{} = review, attrs) do
    case review
         |> Review.changeset(attrs)
         |> Repo.update() do
      {:ok, updated_review} = result ->
        # Load book and author associations for indexing
        review_with_book = Repo.preload(updated_review, book: :author)

        # Update in OpenSearch
        Search.index_review(review_with_book)

        # Invalidate related caches
        Cache.delete(Cache.review_key(review.id))
        Cache.delete_pattern("reviews_list:*")
        Cache.delete_pattern("review_scores:#{review.book_id}")
        Cache.delete_pattern("book_reviews:#{review.book_id}")
        result

      error ->
        error
    end
  end

  @doc """
  Deletes a review.

  ## Examples

      iex> delete_review(review)
      {:ok, %Review{}}

      iex> delete_review(review)
      {:error, %Ecto.Changeset{}}

  """
  def delete_review(%Review{} = review) do
    case Repo.delete(review) do
      {:ok, deleted_review} = result ->
        # Remove from OpenSearch
        Search.remove_review(deleted_review.id)

        # Invalidate related caches
        Cache.delete(Cache.review_key(review.id))
        Cache.delete_pattern("reviews_list:*")
        Cache.delete_pattern("review_scores:#{review.book_id}")
        Cache.delete_pattern("book_reviews:#{review.book_id}")
        result

      error ->
        error
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking review changes.

  ## Examples

      iex> change_review(review)
      %Ecto.Changeset{data: %Review{}}

  """
  def change_review(%Review{} = review, attrs \\ %{}) do
    Review.changeset(review, attrs)
  end

  @doc """
  Returns the list of reviews for a specific book.

  ## Examples

      iex> list_reviews_for_book(book_id)
      [%Review{}, ...]

  """
  def list_reviews_for_book(book_id) do
    cache_key = Cache.book_reviews_key(book_id)

    case Cache.get(cache_key) do
      {:ok, nil} ->
        result =
          from(r in Review, where: r.book_id == ^book_id)
          |> Repo.all()
          |> Repo.preload(:book)

        # 30 minutes in milliseconds
        Cache.put(cache_key, result, 1_800_000)
        result

      {:ok, cached_result} ->
        cached_result
    end
  end

  @doc """
  Returns review statistics for a book (average score, count).

  ## Examples

      iex> get_book_review_stats(book_id)
      %{average_score: 4.2, review_count: 15}

  """
  def get_book_review_stats(book_id) do
    cache_key = Cache.review_scores_key(book_id)

    case Cache.get(cache_key) do
      {:ok, nil} ->
        query =
          from(r in Review,
            where: r.book_id == ^book_id,
            select: %{
              average_score: avg(r.score),
              review_count: count(r.id)
            }
          )

        result =
          case Repo.one(query) do
            %{average_score: nil, review_count: 0} ->
              %{average_score: 0.0, review_count: 0}

            %{average_score: avg, review_count: count} ->
              %{average_score: Float.round(avg, 1), review_count: count}
          end

        # 2 hours in milliseconds
        Cache.put(cache_key, result, 7_200_000)
        result

      {:ok, cached_result} ->
        cached_result
    end
  end
end
