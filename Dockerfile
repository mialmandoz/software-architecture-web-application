FROM elixir:1.15

# Install dependencies
RUN apt-get update && apt-get install -y \
    nodejs npm postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy mix files and install dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get

# Copy everything else
COPY . .

# Expose port
EXPOSE 4000

# Start script that waits for DB, creates/migrates DB (only seeds if empty) and starts server
CMD ["sh", "-c", "while ! pg_isready -h db -p 5432 -U postgres; do echo 'Waiting for database...'; sleep 2; done && mix ecto.create && mix ecto.migrate && if [ $(mix run -e 'IO.puts(WebApplication.Repo.aggregate(WebApplication.Books.Book, :count))' 2>/dev/null || echo 0) -eq 0 ]; then mix run priv/repo/seeds.exs; fi && mix phx.server"]
