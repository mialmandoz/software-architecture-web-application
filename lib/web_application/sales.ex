defmodule WebApplication.Sales do
  @moduledoc """
  The Sales context.
  """

  import Ecto.Query, warn: false
  alias WebApplication.Repo

  alias WebApplication.Sales.Sale

  @doc """
  Returns the list of sales.

  ## Examples

      iex> list_sales()
      [%Sale{}, ...]

  """
  def list_sales do
    Repo.all(Sale)
    |> Repo.preload(book: :author)
  end

  @doc """
  Gets a single sale.

  Raises `Ecto.NoResultsError` if the Sale does not exist.

  ## Examples

      iex> get_sale!(123)
      %Sale{}

      iex> get_sale!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sale!(id) do
    Repo.get!(Sale, id)
    |> Repo.preload(book: :author)
  end

  @doc """
  Creates a sale.

  ## Examples

      iex> create_sale(%{field: value})
      {:ok, %Sale{}}

      iex> create_sale(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sale(attrs \\ %{}) do
    %Sale{}
    |> Sale.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sale.

  ## Examples

      iex> update_sale(sale, %{field: new_value})
      {:ok, %Sale{}}

      iex> update_sale(sale, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sale(%Sale{} = sale, attrs) do
    sale
    |> Sale.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a sale.

  ## Examples

      iex> delete_sale(sale)
      {:ok, %Sale{}}

      iex> delete_sale(sale)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sale(%Sale{} = sale) do
    Repo.delete(sale)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sale changes.

  ## Examples

      iex> change_sale(sale)
      %Ecto.Changeset{data: %Sale{}}

  """
  def change_sale(%Sale{} = sale, attrs \\ %{}) do
    Sale.changeset(sale, attrs)
  end

  @doc """
  Returns the list of sales for a specific book.

  ## Examples

      iex> list_sales_for_book(book_id)
      [%Sale{}, ...]

  """
  def list_sales_for_book(book_id) do
    from(s in Sale, where: s.book_id == ^book_id, order_by: s.year)
    |> Repo.all()
    |> Repo.preload(book: :author)
  end

  @doc """
  Returns the list of sales for a specific year.

  ## Examples

      iex> list_sales_for_year(2023)
      [%Sale{}, ...]

  """
  def list_sales_for_year(year) do
    from(s in Sale, where: s.year == ^year, order_by: [desc: s.sales])
    |> Repo.all()
    |> Repo.preload(book: :author)
  end
end
