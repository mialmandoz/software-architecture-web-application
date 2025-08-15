defmodule WebApplication.Repo do
  use Ecto.Repo,
    otp_app: :web_application,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10
end
