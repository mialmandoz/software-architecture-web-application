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

alias WebApplication.DataGenerator

# Clear existing data and generate fresh dataset
IO.puts("🌱 Seeding database with realistic test data...")

# Generate the dataset as specified in requirements:
# - 50 authors
# - 300 books
# - 1-10 reviews per book
# - 5 years of sales data
DataGenerator.generate_dataset(
  authors: 50,
  books: 300,
  reviews_per_book: {1, 10},
  sales_years: 5,
  clear_existing: true
)

IO.puts("🎉 Database seeding complete!")
IO.puts("")
IO.puts("📊 You can now:")
IO.puts("   • View all CRUD operations at http://localhost:4000")
IO.puts("   • Check author statistics at http://localhost:4000/authors/statistics")
IO.puts("   • Test sorting and filtering functionality")
IO.puts("")
IO.puts("💡 To generate different amounts of data:")
IO.puts("   • Small dataset: WebApplication.DataGenerator.generate_small()")
IO.puts("   • Large dataset: WebApplication.DataGenerator.generate_large()")
IO.puts("   • Custom: WebApplication.DataGenerator.generate_dataset(authors: 25, books: 100)")
