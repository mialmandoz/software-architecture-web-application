defmodule WebApplication.DataGenerator do
  @moduledoc """
  Generates realistic test data for the book review application.
  Can be used from seeds.exs or custom mix tasks.
  """

  alias WebApplication.{Repo, Authors, Books, Reviews, Sales}

  @doc """
  Generate a complete dataset with the specified counts.

  Options:
  - authors: number of authors to create (default: 50)
  - books: number of books to create (default: 300)
  - reviews_per_book: range like {1, 10} (default: {1, 10})
  - sales_years: number of years of sales data (default: 5)
  - clear_existing: whether to clear existing data first (default: false)
  """
  def generate_dataset(opts \\ []) do
    authors = Keyword.get(opts, :authors, 50)
    books = Keyword.get(opts, :books, 300)
    reviews_per_book = Keyword.get(opts, :reviews_per_book, {1, 10})
    sales_years = Keyword.get(opts, :sales_years, 5)
    clear_existing = Keyword.get(opts, :clear_existing, false)

    if clear_existing do
      IO.puts("🗑️  Clearing existing data...")
      clear_all_data()
    end

    IO.puts("📊 Generating dataset: #{authors} authors, #{books} books")

    # Generate in sequence to maintain relationships
    author_list = generate_authors(authors)
    book_list = generate_books(books, author_list)
    generate_reviews(book_list, reviews_per_book)
    generate_sales(book_list, sales_years)

    IO.puts("✅ Dataset generation complete!")
  end

  @doc "Generate small dataset for development"
  def generate_small,
    do: generate_dataset(authors: 10, books: 50, reviews_per_book: {1, 5}, sales_years: 3)

  @doc "Generate large dataset for testing"
  def generate_large,
    do: generate_dataset(authors: 100, books: 500, reviews_per_book: {1, 15}, sales_years: 7)

  defp clear_all_data do
    Repo.delete_all(WebApplication.Sales.Sale)
    Repo.delete_all(WebApplication.Reviews.Review)
    Repo.delete_all(WebApplication.Books.Book)
    Repo.delete_all(WebApplication.Authors.Author)
  end

  defp generate_authors(count) do
    IO.puts("👨‍💼 Creating #{count} authors...")

    # Realistic data pools
    countries = [
      "United States",
      "United Kingdom",
      "Canada",
      "Australia",
      "France",
      "Germany",
      "Spain",
      "Italy",
      "Japan",
      "Brazil",
      "India",
      "South Africa",
      "Netherlands",
      "Sweden",
      "Norway",
      "Ireland",
      "New Zealand",
      "Argentina",
      "Mexico",
      "Russia"
    ]

    first_names = [
      "James",
      "Mary",
      "John",
      "Patricia",
      "Robert",
      "Jennifer",
      "Michael",
      "Linda",
      "William",
      "Elizabeth",
      "David",
      "Barbara",
      "Richard",
      "Susan",
      "Joseph",
      "Jessica",
      "Thomas",
      "Sarah",
      "Christopher",
      "Karen",
      "Charles",
      "Nancy",
      "Daniel",
      "Lisa",
      "Matthew",
      "Betty",
      "Anthony",
      "Helen",
      "Mark",
      "Sandra",
      "Donald",
      "Donna"
    ]

    last_names = [
      "Smith",
      "Johnson",
      "Williams",
      "Brown",
      "Jones",
      "Garcia",
      "Miller",
      "Davis",
      "Rodriguez",
      "Martinez",
      "Hernandez",
      "Lopez",
      "Gonzalez",
      "Wilson",
      "Anderson",
      "Thomas",
      "Taylor",
      "Moore",
      "Jackson",
      "Martin",
      "Lee",
      "Perez",
      "Thompson",
      "White",
      "Harris",
      "Sanchez",
      "Clark",
      "Ramirez",
      "Lewis",
      "Robinson",
      "Walker"
    ]

    for i <- 1..count do
      first = Enum.random(first_names)
      last = Enum.random(last_names)

      attrs = %{
        name: "#{first} #{last}",
        country_of_origin: Enum.random(countries),
        date_of_birth: random_date(1920, 1990),
        short_description: generate_author_bio(first, last)
      }

      {:ok, author} = Authors.create_author(attrs)
      if rem(i, 10) == 0, do: IO.write(".")
      author
    end
    |> tap(fn _ -> IO.puts(" ✓") end)
  end

  defp generate_books(count, authors) do
    IO.puts("📚 Creating #{count} books...")

    # Book title components for variety
    adjectives = [
      "Silent",
      "Hidden",
      "Lost",
      "Forgotten",
      "Ancient",
      "Mysterious",
      "Golden",
      "Dark"
    ]

    nouns = ["Journey", "Secret", "Truth", "Path", "Garden", "River", "Mountain", "Ocean"]

    genres = [
      "Mystery",
      "Romance",
      "Science Fiction",
      "Fantasy",
      "Thriller",
      "Historical Fiction",
      "Literary Fiction",
      "Adventure",
      "Drama",
      "Biography",
      "Horror",
      "Comedy"
    ]

    for i <- 1..count do
      author = Enum.random(authors)

      # Generate varied book titles
      title =
        case rem(i, 3) do
          0 -> "#{Enum.random(adjectives)} #{Enum.random(nouns)}"
          1 -> "The #{Enum.random(adjectives)} #{Enum.random(nouns)}"
          2 -> "#{Enum.random(nouns)} of #{Enum.random(adjectives)}ness"
        end

      genre = Enum.random(genres)

      attrs = %{
        name: "#{title} #{if i > 20, do: "- Book #{i}", else: ""}",
        summary: generate_book_summary(genre),
        date_of_publication: random_date(1950, 2024),
        number_of_sales: Enum.random(500..100_000),
        author_id: author.id
      }

      {:ok, book} = Books.create_book(attrs)
      if rem(i, 25) == 0, do: IO.write(".")
      book
    end
    |> tap(fn _ -> IO.puts(" ✓") end)
  end

  defp generate_reviews(books, {min_reviews, max_reviews}) do
    total_books = length(books)
    IO.puts("⭐ Creating reviews for #{total_books} books...")

    positive_reviews = [
      "An absolutely captivating read that kept me turning pages late into the night.",
      "Beautifully written with complex characters and an engaging plot.",
      "A masterpiece of storytelling that will stay with you long after reading.",
      "Compelling narrative with unexpected twists and emotional depth.",
      "Well-crafted prose and excellent character development throughout."
    ]

    negative_reviews = [
      "The plot felt predictable and the characters lacked depth.",
      "Struggled to get through this one - pacing was quite slow.",
      "Had potential but didn't quite deliver on its promises.",
      "Some interesting ideas but the execution fell short."
    ]

    count = 0

    for book <- books do
      num_reviews = Enum.random(min_reviews..max_reviews)

      for _ <- 1..num_reviews do
        score = Enum.random(1..5)

        review_text =
          if score >= 4, do: Enum.random(positive_reviews), else: Enum.random(negative_reviews)

        attrs = %{
          score: score,
          review: review_text,
          number_of_upvotes: Enum.random(0..200),
          book_id: book.id
        }

        {:ok, _review} = Reviews.create_review(attrs)
        count = count + 1
        if rem(count, 50) == 0, do: IO.write(".")
      end
    end

    IO.puts(" ✓")
  end

  defp generate_sales(books, years_count) do
    current_year = Date.utc_today().year
    years = (current_year - years_count + 1)..current_year
    total_sales = length(books) * years_count

    IO.puts("💰 Creating #{total_sales} sales records...")

    count = 0

    for book <- books, year <- years do
      # More realistic sales distribution - newer books tend to sell more
      base_sales = Enum.random(100..5000)
      year_multiplier = if year >= current_year - 2, do: Enum.random(2..5), else: 1

      attrs = %{
        sales: base_sales * year_multiplier,
        year: year,
        book_id: book.id
      }

      {:ok, _sale} = Sales.create_sale(attrs)
      count = count + 1
      if rem(count, 100) == 0, do: IO.write(".")
    end

    IO.puts(" ✓")
  end

  # Helper functions for realistic content generation
  defp random_date(start_year, end_year) do
    year = Enum.random(start_year..end_year)
    month = Enum.random(1..12)
    # Safe day range for all months
    day = Enum.random(1..28)
    Date.new!(year, month, day)
  end

  defp generate_author_bio(first_name, last_name) do
    achievements = [
      "bestselling",
      "award-winning",
      "critically acclaimed",
      "internationally recognized"
    ]

    specialties = [
      "contemporary fiction",
      "historical novels",
      "mystery thrillers",
      "literary fiction",
      "science fiction",
      "fantasy epics"
    ]

    achievement = Enum.random(achievements)
    specialty = Enum.random(specialties)

    "#{first_name} #{last_name} is a #{achievement} author known for #{specialty}. Their works have captivated readers worldwide with compelling storytelling and rich character development."
  end

  defp generate_book_summary(genre) do
    themes = [
      "love and loss",
      "redemption and forgiveness",
      "courage and sacrifice",
      "family and loyalty",
      "justice and truth",
      "hope and resilience"
    ]

    settings = [
      "ancient civilizations",
      "modern urban landscapes",
      "mystical realms",
      "post-apocalyptic worlds",
      "small-town communities",
      "exotic locations"
    ]

    theme = Enum.random(themes)
    setting = Enum.random(settings)

    "A captivating #{String.downcase(genre)} novel that explores themes of #{theme}. This compelling story takes readers on an unforgettable journey through #{setting}."
  end
end
