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

# Create sample authors
Authors.create_author(%{
  name: "F. Scott Fitzgerald",
  date_of_birth: ~D[1896-09-24],
  country_of_origin: "United States",
  short_description: "American novelist and short story writer, known for his depictions of the Jazz Age and the American Dream."
})

Authors.create_author(%{
  name: "Harper Lee",
  date_of_birth: ~D[1926-04-28],
  country_of_origin: "United States",
  short_description: "American novelist best known for her 1960 novel To Kill a Mockingbird, which won the Pulitzer Prize."
})

Authors.create_author(%{
  name: "George Orwell",
  date_of_birth: ~D[1903-06-25],
  country_of_origin: "United Kingdom",
  short_description: "English novelist and essayist, known for his works of social criticism and opposition to totalitarianism."
})

Authors.create_author(%{
  name: "Jane Austen",
  date_of_birth: ~D[1775-12-16],
  country_of_origin: "United Kingdom",
  short_description: "English novelist known for her wit, social commentary, and realism in depicting the lives of the landed gentry."
})

# Create sample books
Books.create_book(%{
  name: "The Great Gatsby",
  summary: "A classic American novel set in the Jazz Age, exploring themes of wealth, love, and the American Dream through the eyes of narrator Nick Carraway.",
  date_of_publication: ~D[1925-04-10],
  number_of_sales: 25000000
})

Books.create_book(%{
  name: "To Kill a Mockingbird",
  summary: "A gripping tale of racial injustice and childhood innocence in the American South, told through the perspective of young Scout Finch.",
  date_of_publication: ~D[1960-07-11],
  number_of_sales: 40000000
})

Books.create_book(%{
  name: "1984",
  summary: "A dystopian social science fiction novel that explores themes of totalitarianism, surveillance, and individual freedom in a future society.",
  date_of_publication: ~D[1949-06-08],
  number_of_sales: 30000000
})

Books.create_book(%{
  name: "Pride and Prejudice",
  summary: "A romantic novel that critiques the British landed gentry at the end of the 18th century, focusing on Elizabeth Bennet and Mr. Darcy.",
  date_of_publication: ~D[1813-01-28],
  number_of_sales: 20000000
})
