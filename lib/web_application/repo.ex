defmodule WebApplication.Repo do
  use Ecto.Repo,
    otp_app: :web_application,
    adapter: Ecto.Adapters.Postgres
end
