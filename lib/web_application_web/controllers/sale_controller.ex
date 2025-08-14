defmodule WebApplicationWeb.SaleController do
  use WebApplicationWeb, :controller

  alias WebApplication.Sales
  alias WebApplication.Sales.Sale
  alias WebApplication.Books

  def index(conn, params) do
    sales = Sales.list_sales(params)
    render(conn, :index, sales: sales, params: params)
  end

  def show(conn, %{"id" => id}) do
    sale = Sales.get_sale!(id)
    render(conn, :show, sale: sale)
  end

  def new(conn, _params) do
    changeset = Sales.change_sale(%Sale{})
    books = Books.list_books()
    render(conn, :new, changeset: changeset, books: books)
  end

  def create(conn, %{"sale" => sale_params}) do
    case Sales.create_sale(sale_params) do
      {:ok, sale} ->
        conn
        |> put_flash(:info, "Sale created successfully.")
        |> redirect(to: ~p"/sales/#{sale}")

      {:error, %Ecto.Changeset{} = changeset} ->
        books = Books.list_books()
        render(conn, :new, changeset: changeset, books: books)
    end
  end

  def edit(conn, %{"id" => id}) do
    sale = Sales.get_sale!(id)
    changeset = Sales.change_sale(sale)
    books = Books.list_books()
    render(conn, :edit, sale: sale, changeset: changeset, books: books)
  end

  def update(conn, %{"id" => id, "sale" => sale_params}) do
    sale = Sales.get_sale!(id)

    case Sales.update_sale(sale, sale_params) do
      {:ok, sale} ->
        conn
        |> put_flash(:info, "Sale updated successfully.")
        |> redirect(to: ~p"/sales/#{sale}")

      {:error, %Ecto.Changeset{} = changeset} ->
        books = Books.list_books()
        render(conn, :edit, sale: sale, changeset: changeset, books: books)
    end
  end

  def delete(conn, %{"id" => id}) do
    sale = Sales.get_sale!(id)
    {:ok, _sale} = Sales.delete_sale(sale)

    conn
    |> put_flash(:info, "Sale deleted successfully.")
    |> redirect(to: ~p"/sales")
  end
end
