# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     WebApplication.Repo.insert!(%WebApplication.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias WebApplication.Books
alias WebApplication.Authors
alias WebApplication.Reviews
alias WebApplication.Sales

# Create sample authors
{:ok, fitzgerald} =
  Authors.create_author(%{
    name: "F. Scott Fitzgerald",
    date_of_birth: ~D[1896-09-24],
    country_of_origin: "United States",
    short_description:
      "American novelist and short story writer, known for his depictions of the Jazz Age and the American Dream."
  })

{:ok, harper_lee} =
  Authors.create_author(%{
    name: "Harper Lee",
    date_of_birth: ~D[1926-04-28],
    country_of_origin: "United States",
    short_description:
      "American novelist best known for her 1960 novel To Kill a Mockingbird, which won the Pulitzer Prize."
  })

{:ok, orwell} =
  Authors.create_author(%{
    name: "George Orwell",
    date_of_birth: ~D[1903-06-25],
    country_of_origin: "United Kingdom",
    short_description:
      "English novelist and essayist, known for his works of social criticism and opposition to totalitarianism."
  })

{:ok, austen} =
  Authors.create_author(%{
    name: "Jane Austen",
    date_of_birth: ~D[1775-12-16],
    country_of_origin: "United Kingdom",
    short_description:
      "English novelist known for her wit, social commentary, and realism in depicting the lives of the landed gentry."
  })

# Create sample books with authors
{:ok, gatsby} =
  Books.create_book(%{
    name: "The Great Gatsby",
    author_id: fitzgerald.id,
    summary:
      "A classic American novel set in the Jazz Age, exploring themes of wealth, love, and the American Dream through the eyes of narrator Nick Carraway.",
    date_of_publication: ~D[1925-04-10],
    number_of_sales: 25_000_000
  })

{:ok, mockingbird} =
  Books.create_book(%{
    name: "To Kill a Mockingbird",
    author_id: harper_lee.id,
    summary:
      "A gripping tale of racial injustice and childhood innocence in the American South, told through the perspective of young Scout Finch.",
    date_of_publication: ~D[1960-07-11],
    number_of_sales: 40_000_000
  })

{:ok, nineteen_eighty_four} =
  Books.create_book(%{
    name: "1984",
    author_id: orwell.id,
    summary:
      "A dystopian social science fiction novel that explores themes of totalitarianism, surveillance, and individual freedom in a future society.",
    date_of_publication: ~D[1949-06-08],
    number_of_sales: 30_000_000
  })

{:ok, pride_prejudice} =
  Books.create_book(%{
    name: "Pride and Prejudice",
    author_id: austen.id,
    summary:
      "A romantic novel that critiques the British landed gentry at the end of the 18th century, focusing on Elizabeth Bennet and Mr. Darcy.",
    date_of_publication: ~D[1813-01-28],
    number_of_sales: 20_000_000
  })

# Create sample reviews
Reviews.create_review(%{
  book_id: gatsby.id,
  review:
    "A masterpiece of American literature! Fitzgerald's prose is absolutely beautiful, and his portrayal of the Jazz Age is both glamorous and tragic. The symbolism is rich and the characters are unforgettable.",
  score: 5,
  number_of_upvotes: 127
})

Reviews.create_review(%{
  book_id: mockingbird.id,
  review:
    "An incredibly powerful and moving story that tackles difficult themes with grace and wisdom. Scout's perspective as a child makes the heavy topics accessible while maintaining their impact.",
  score: 5,
  number_of_upvotes: 203
})

Reviews.create_review(%{
  book_id: nineteen_eighty_four.id,
  review:
    "Chilling and prophetic. Orwell's vision of a totalitarian future feels more relevant than ever. The concepts of doublethink and Big Brother have become part of our cultural lexicon for good reason.",
  score: 4,
  number_of_upvotes: 89
})

Reviews.create_review(%{
  book_id: pride_prejudice.id,
  review:
    "Austen's wit and social commentary are brilliant. Elizabeth Bennet is one of literature's greatest heroines, and the romance with Darcy is perfectly developed. A timeless classic.",
  score: 5,
  number_of_upvotes: 156
})

Reviews.create_review(%{
  book_id: gatsby.id,
  review:
    "While beautifully written, I found the characters somewhat unlikeable and the pacing slow at times. Still, it's an important work that captures the essence of its era.",
  score: 3,
  number_of_upvotes: 45
})

# Create sample sales data
Sales.create_sale(%{
  book_id: gatsby.id,
  year: 2020,
  sales: 1_500_000
})

Sales.create_sale(%{
  book_id: gatsby.id,
  year: 2021,
  sales: 1_750_000
})

Sales.create_sale(%{
  book_id: gatsby.id,
  year: 2022,
  sales: 1_600_000
})

Sales.create_sale(%{
  book_id: mockingbird.id,
  year: 2020,
  sales: 2_200_000
})

Sales.create_sale(%{
  book_id: mockingbird.id,
  year: 2021,
  sales: 2_400_000
})

Sales.create_sale(%{
  book_id: mockingbird.id,
  year: 2022,
  sales: 2_100_000
})

Sales.create_sale(%{
  book_id: nineteen_eighty_four.id,
  year: 2020,
  sales: 1_800_000
})

Sales.create_sale(%{
  book_id: nineteen_eighty_four.id,
  year: 2021,
  sales: 2_000_000
})

Sales.create_sale(%{
  book_id: nineteen_eighty_four.id,
  year: 2022,
  sales: 1_900_000
})

Sales.create_sale(%{
  book_id: pride_prejudice.id,
  year: 2020,
  sales: 1_200_000
})

Sales.create_sale(%{
  book_id: pride_prejudice.id,
  year: 2021,
  sales: 1_350_000
})

Sales.create_sale(%{
  book_id: pride_prejudice.id,
  year: 2022,
  sales: 1_400_000
})
