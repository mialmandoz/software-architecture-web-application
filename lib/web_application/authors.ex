defmodule WebApplication.Authors do
  @moduledoc """
  The Authors context.
  """

  import Ecto.Query, warn: false
  alias WebApplication.Repo
  alias WebApplication.Cache

  alias WebApplication.Authors.Author

  @doc """
  Returns all authors without pagination for use in form dropdowns.

  ## Examples

      iex> list_all_authors()
      [%Author{}, ...]

  """
  def list_all_authors() do
    cache_key = "authors_all"

    case Cache.get(cache_key) do
      {:ok, nil} ->
        result =
          from(a in Author, order_by: [asc: a.name])
          |> Repo.all()

        # 30 minutes
        Cache.put(cache_key, result, 1_800_000)
        result

      {:ok, cached_result} ->
        cached_result
    end
  end

  @doc """
  Returns a paginated list of authors with optional filtering.

  ## Examples

      iex> list_authors()
      %Scrivener.Page{entries: [%Author{}, ...], ...}

      iex> list_authors(%{"filter_name" => "smith", "page" => "2"})
      %Scrivener.Page{entries: [%Author{}, ...], ...}

  """
  def list_authors(params \\ %{}) do
    filter_name = Map.get(params, "filter_name", "")
    filter_country = Map.get(params, "filter_country", "")
    page = Map.get(params, "page", "1") |> String.to_integer()

    cache_key =
      Cache.authors_list_key(%{
        filter_name: filter_name,
        filter_country: filter_country,
        page: page
      })

    case Cache.get(cache_key) do
      {:ok, nil} ->
        query = from(a in Author)

        # Apply name filter
        query =
          if filter_name != "" do
            from a in query,
              where: ilike(a.name, ^"%#{filter_name}%")
          else
            query
          end

        # Apply country filter
        query =
          if filter_country != "" do
            from a in query,
              where: ilike(a.country_of_origin, ^"%#{filter_country}%")
          else
            query
          end

        # Order by name for consistent display
        query = from a in query, order_by: [asc: a.name]

        result = Repo.paginate(query, page: page, page_size: 10)
        # 5 minutes
        Cache.put(cache_key, result, 300_000)
        result

      {:ok, cached_result} ->
        cached_result
    end
  end

  @doc """
  Gets author statistics with aggregated data including number of books, average score, and total sales.

  ## Examples

      iex> get_author_statistics("name", "asc", "")
      [%{author: %Author{}, book_count: 2, avg_score: 4.5, total_sales: 50000000}, ...]

  """
  def get_author_statistics(sort_by \\ "name", sort_order \\ "asc", filter_name \\ "") do
    cache_key =
      Cache.author_stats_key(%{
        sort_by: sort_by,
        sort_order: sort_order,
        filter_name: filter_name
      })

    case Cache.get(cache_key) do
      {:ok, nil} ->
        query =
          from a in Author,
            left_join: b in assoc(a, :books),
            left_join: r in assoc(b, :reviews),
            left_join: s in assoc(b, :sales),
            group_by: [a.id, a.name, a.date_of_birth, a.country_of_origin, a.short_description],
            select: %{
              author: a,
              book_count: fragment("COUNT(DISTINCT ?)", b.id),
              avg_score: coalesce(avg(r.score), 0.0),
              total_sales: coalesce(sum(s.sales), 0)
            }

        # Apply name filter if provided
        query =
          if filter_name != "" do
            from [a, b, r, s] in query,
              where: ilike(a.name, ^"%#{filter_name}%")
          else
            query
          end

        # Apply sorting
        query =
          case {sort_by, sort_order} do
            {"name", "asc"} ->
              from [a, b, r, s] in query, order_by: [asc: a.name]

            {"name", "desc"} ->
              from [a, b, r, s] in query, order_by: [desc: a.name]

            {"book_count", "asc"} ->
              from [a, b, r, s] in query, order_by: [asc: fragment("COUNT(DISTINCT ?)", b.id)]

            {"book_count", "desc"} ->
              from [a, b, r, s] in query, order_by: [desc: fragment("COUNT(DISTINCT ?)", b.id)]

            {"avg_score", "asc"} ->
              from [a, b, r, s] in query, order_by: [asc: coalesce(avg(r.score), 0.0)]

            {"avg_score", "desc"} ->
              from [a, b, r, s] in query, order_by: [desc: coalesce(avg(r.score), 0.0)]

            {"total_sales", "asc"} ->
              from [a, b, r, s] in query, order_by: [asc: coalesce(sum(s.sales), 0)]

            {"total_sales", "desc"} ->
              from [a, b, r, s] in query, order_by: [desc: coalesce(sum(s.sales), 0)]

            {"country", "asc"} ->
              from [a, b, r, s] in query, order_by: [asc: a.country_of_origin]

            {"country", "desc"} ->
              from [a, b, r, s] in query, order_by: [desc: a.country_of_origin]

            _ ->
              from [a, b, r, s] in query, order_by: [asc: a.name]
          end

        result = Repo.all(query)
        # 10 minutes
        Cache.put(cache_key, result, 600_000)
        result

      {:ok, cached_result} ->
        cached_result
    end
  end

  @doc """
  Gets a single author.

  Raises `Ecto.NoResultsError` if the Author does not exist.

  ## Examples

      iex> get_author!(123)
      %Author{}

      iex> get_author!(456)
      ** (Ecto.NoResultsError)

  """
  def get_author!(id) do
    cache_key = Cache.author_key(id)

    case Cache.get(cache_key) do
      {:ok, nil} ->
        result = Repo.get!(Author, id)
        # 1 hour
        Cache.put(cache_key, result, 3_600_000)
        result

      {:ok, cached_result} ->
        cached_result
    end
  end

  @doc """
  Creates a author.

  ## Examples

      iex> create_author(%{field: value})
      {:ok, %Author{}}

      iex> create_author(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_author(attrs \\ %{}) do
    case %Author{}
         |> Author.changeset(attrs)
         |> Repo.insert() do
      {:ok, _author} = result ->
        # Invalidate related caches
        Cache.delete_pattern("authors_list:*")
        Cache.delete_pattern("author_stats:*")
        Cache.delete("authors_all")
        result

      error ->
        error
    end
  end

  @doc """
  Updates a author.

  ## Examples

      iex> update_author(author, %{field: new_value})
      {:ok, %Author{}}

      iex> update_author(author, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_author(%Author{} = author, attrs) do
    case author
         |> Author.changeset(attrs)
         |> Repo.update() do
      {:ok, _updated_author} = result ->
        # Invalidate related caches
        Cache.delete(Cache.author_key(author.id))
        Cache.delete_pattern("authors_list:*")
        Cache.delete_pattern("author_stats:*")
        Cache.delete("authors_all")
        result

      error ->
        error
    end
  end

  @doc """
  Deletes a author.

  ## Examples

      iex> delete_author(author)
      {:ok, %Author{}}

      iex> delete_author(author)
      {:error, %Ecto.Changeset{}}

  """
  def delete_author(%Author{} = author) do
    case Repo.delete(author) do
      {:ok, _deleted_author} = result ->
        # Invalidate related caches
        Cache.delete(Cache.author_key(author.id))
        Cache.delete_pattern("authors_list:*")
        Cache.delete_pattern("author_stats:*")
        Cache.delete("authors_all")
        result

      error ->
        error
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking author changes.

  ## Examples

      iex> change_author(author)
      %Ecto.Changeset{data: %Author{}}

  """
  def change_author(%Author{} = author, attrs \\ %{}) do
    Author.changeset(author, attrs)
  end
end
