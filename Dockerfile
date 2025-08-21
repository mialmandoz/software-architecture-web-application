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

# Copy and make startup script executable
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose port
EXPOSE 4000

# Use startup script
CMD ["/start.sh"]
