# WebApplication

Web application developed with **Phoenix Framework** and **PostgreSQL**.

---

## 1. Requirements

Only **Docker** is required to run this application:

### macOS

```bash
# Install Docker Desktop
brew install --cask docker
```

### Linux (Ubuntu/Debian)

```bash
# Install Docker
sudo apt install docker.io docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

### Windows

- **Install Docker Desktop:** https://www.docker.com/products/docker-desktop
- **Install Git:** https://git-scm.com/

---

## 2. Project Installation

### Docker Setup (Recommended)

```bash
# Clone the repository
git clone https://github.com/mialmandoz/software-architecture-web-application
cd software-architecture-web-application

# It's recommended to delete all previous containers and volumes before building the new ones
docker-compose down -v --remove-orphans

# Build and start the application with Docker (basic version)
docker-compose --profile normal up --build

# Build and start the application with Docker (with Redis caching)
docker-compose --profile cache up --build

# Build and start the application with Docker (with OpenSearch for advanced search)
docker-compose --profile search up --build

# Build and start the application with Docker (with Nginx reverse proxy)
docker-compose --profile normal --profile nginx up --build

# Build and start the application with Docker (with all features: Nginx + Redis + OpenSearch)
docker-compose --profile all up --build
```

The application will be available at:

- **Direct access:** http://localhost:4000 (when using profiles without nginx)
- **Through Nginx:** http://localhost:80 (when using nginx or all profiles)

### Cache Behavior

**Without Redis (`--profile normal`):**

- Uses direct database queries
- No cache messages in logs
- Startup message: ` No caching - Redis disabled`

**With Redis (`--profile cache`):**

- Caches:
  - book lists
  - author lists
  - review lists
  - Top 10 Rated Books
  - Top 50 Selling Books
  - Author statistics
- Shows cache HIT/MISS/PUT messages in logs
- Startup message: ` Redis caching enabled`
- Cache automatically invalidates when data is modified

---

## Troubleshooting

### Docker Network Errors

If you encounter network errors or connection issues, clean up Docker resources:

```bash
# Stop all containers
docker-compose down

# Remove all containers, networks, and volumes
docker system prune -a --volumes

# Remove all Docker networks
docker network prune
```

Then restart the application with your preferred profile.

---

## 3. Project Structure

```
web_application/
├── lib/                           # Main application code
│   ├── web_application/           # Business logic and contexts
│   │   ├── application.ex         # Application configuration
│   │   ├── repo.ex               # Ecto repository
│   │   ├── mailer.ex             # Email configuration
│   │   ├── cache.ex              # Redis/In-memory cache module
│   │   ├── search.ex             # OpenSearch integration for full-text search
│   │   ├── data_generator.ex     # Test data generator
│   │   ├── authors/              # Authors context
│   │   │   └── author.ex         # Schema and validations
│   │   ├── authors.ex            # CRUD functions for authors (with caching)
│   │   ├── books/                # Books context
│   │   │   └── book.ex           # Schema and validations
│   │   ├── books.ex              # CRUD functions for books (with filters & caching)
│   │   ├── reviews/              # Reviews context
│   │   │   └── review.ex         # Schema and validations
│   │   ├── reviews.ex            # CRUD functions for reviews (with caching)
│   │   ├── sales/                # Sales context
│   │   │   └── sale.ex           # Schema and validations
│   │   └── sales.ex              # CRUD functions for sales (with filters)
│   ├── web_application_web/       # Web layer (controllers, views, etc.)
│   │   ├── components/           # Reusable components
│   │   │   ├── core_components.ex # Base components (includes pagination)
│   │   │   ├── layouts.ex        # Application layouts
│   │   │   └── layouts/          # Layout templates
│   │   ├── controllers/          # Web controllers
│   │   │   ├── author_controller.ex    # Authors CRUD
│   │   │   ├── author_html/            # Authors HTML views
│   │   │   │   ├── index.html.heex     # List with pagination
│   │   │   │   ├── show.html.heex      # Author detail
│   │   │   │   ├── new.html.heex       # Create author
│   │   │   │   ├── edit.html.heex      # Edit author
│   │   │   │   └── author_form.html.heex # Form
│   │   │   ├── author_html.ex          # View helpers
│   │   │   ├── book_controller.ex      # Books CRUD
│   │   │   ├── book_html/              # Books HTML views
│   │   │   │   ├── index.html.heex     # List with filters and pagination
│   │   │   │   ├── search.html.heex    # Advanced search interface
│   │   │   │   ├── show.html.heex      # Book detail
│   │   │   │   ├── new.html.heex       # Create book
│   │   │   │   ├── edit.html.heex      # Edit book
│   │   │   │   └── book_form.html.heex # Form
│   │   │   ├── book_html.ex            # View helpers
│   │   │   ├── review_controller.ex    # Reviews CRUD
│   │   │   ├── review_html/            # Reviews HTML views
│   │   │   │   ├── index.html.heex     # List with pagination
│   │   │   │   ├── search.html.heex    # Advanced search interface
│   │   │   │   ├── show.html.heex      # Review detail
│   │   │   │   ├── new.html.heex       # Create review
│   │   │   │   ├── edit.html.heex      # Edit review
│   │   │   │   └── review_form.html.heex # Form
│   │   │   ├── review_html.ex          # View helpers
│   │   │   ├── sale_controller.ex      # Sales CRUD
│   │   │   ├── sale_html/              # Sales HTML views
│   │   │   │   ├── index.html.heex     # List with filters and pagination
│   │   │   │   ├── show.html.heex      # Sale detail
│   │   │   │   ├── new.html.heex       # Create sale
│   │   │   │   ├── edit.html.heex      # Edit sale
│   │   │   │   └── sale_form.html.heex # Form
│   │   │   ├── sale_html.ex            # View helpers
│   │   │   ├── page_controller.ex      # Main page
│   │   │   ├── page_html/              # Main page view
│   │   │   │   └── home.html.heex      # Home page
│   │   │   ├── page_html.ex            # Page helpers
│   │   │   ├── error_html.ex           # HTML error handling
│   │   │   └── error_json.ex           # JSON error handling
│   │   ├── endpoint.ex               # Endpoint configuration
│   │   ├── router.ex                 # Application routes
│   │   ├── gettext.ex                # Internationalization
│   │   └── telemetry.ex              # Metrics and monitoring
│   └── web_application.ex            # Main module
├── assets/                           # Frontend resources
│   ├── css/
│   │   └── app.css                   # Main styles (Tailwind CSS)
│   ├── js/
│   │   └── app.js                    # Main JavaScript
│   ├── vendor/                       # External libraries
│   │   ├── daisyui-theme.js         # DaisyUI themes
│   │   ├── daisyui.js               # DaisyUI components
│   │   └── heroicons.js             # Icons
│   └── tsconfig.json                # TypeScript configuration
├── config/                          # Application configuration
│   ├── config.exs                   # General configuration
│   ├── dev.exs                      # Development configuration
│   ├── prod.exs                     # Production configuration
│   ├── runtime.exs                  # Runtime configuration
│   └── test.exs                     # Test configuration
├── priv/                            # Private files
│   ├── gettext/                     # Translation files
│   │   ├── en/                      # English translations
│   │   └── errors.pot               # Error template
│   ├── repo/                        # Database
│   │   ├── migrations/              # DB migrations
│   │   │   ├── 20250812184324_create_books.exs
│   │   │   ├── 20250812185146_create_authors.exs
│   │   │   ├── 20250812195954_create_reviews.exs
│   │   │   ├── 20250812200602_add_author_to_books.exs
│   │   │   ├── 20250812201612_create_sales.exs
│   │   │   └── 20250816192744_update_author_books_cascade_delete.exs
│   │   └── seeds.exs                # Initial data
│   └── static/                      # Static files
│       ├── images/                  # Images
│       ├── favicon.ico              # Site icon
│       └── robots.txt               # Robots configuration
├── test/                            # Automated tests
│   ├── support/                     # Test support
│   │   ├── conn_case.ex            # Connection test cases
│   │   └── data_case.ex            # Data test cases
│   ├── web_application_web/         # Web tests
│   │   └── controllers/             # Controller tests
│   └── test_helper.exs              # Test configuration
├── nginx/                           # Nginx configuration
│   └── templates/                   # Nginx template files
│       └── default.conf.template    # Reverse proxy configuration
├── .formatter.exs                   # Formatter configuration
├── .gitignore                       # Files ignored by Git
├── AGENTS.md                        # Agents documentation
├── Dockerfile                       # Docker container configuration
├── README.md                        # This file
├── docker-compose.yml               # Multi-service configuration (PostgreSQL + Redis)
├── mix.exs                          # Project dependencies and configuration
├── mix.lock                         # Exact dependency versions
└── start.sh                         # Docker startup script
```

### Cache Implementation

The application includes a sophisticated caching system with Redis support:

**Cache Module (`lib/web_application/cache.ex`):**

- **Automatic fallback:** Uses Redis when available, falls back to no-cache mode when Redis is disabled
- **Environment detection:** Automatically detects Redis availability via `REDIS_HOST` environment variable
- **Cache operations:** Supports get, put, delete, pattern deletion, and statistics
- **TTL support:** Configurable time-to-live for cached items
- **Logging:** Comprehensive cache operation logging with emojis for easy debugging

**Dependencies:**

- **Cachex:** In-memory caching library for Elixir
- **Redix:** Redis client for Elixir

**Docker Profiles:**

- **`normal` profile:** Runs without Redis (direct database queries)
- **`cache` profile:** Includes Redis service for caching

**Cached Data:**

- Book lists and individual books (2-hour TTL)
- Author lists and statistics (30-minute TTL)
- Review lists and scores
- Top-rated and best-selling book statistics
- Automatic cache invalidation on data modifications

### Search Implementation

The application includes an advanced search feature with OpenSearch integration:

**Search Module (`lib/web_application/search.ex`):**

- **Fallback:** Uses database search when OpenSearch is unavailable
- **Environment detection:** Automatically detects OpenSearch availability via `OPENSEARCH_HOST` environment variable
- **Search operations:** Supports book and review search with pagination and fuzzy matching
- **Logging:** Comprehensive search operation logging with emojis for easy debugging

**Dependencies:**

- **Req:** HTTP client for Elixir

**Docker Profiles:**

- **`normal` profile:** Runs without OpenSearch (direct database queries)
- **`search` profile:** Includes OpenSearch service for search

**Search Data:**

- Book search results (10 items per page)
- Review search results (10 items per page)

---

## 4. Useful Resources

- [Phoenix Framework](https://hexdocs.pm/phoenix)
- [Elixir](https://elixir-lang.org/docs.html)
- [Ecto ORM](https://hexdocs.pm/ecto)
- [Docker Compose](https://docs.docker.com/compose/)

---

## 5. Implemented Features

- **Complete CRUD** for Authors, Books, Reviews and Sales
- **Pagination** in all index views (10 items per page)
- **Search filters** in books (by title, author and description)
- **Entity relationships** (books-authors, reviews-books, etc.)
- **Validations** in all forms
- **Modern interface** with DaisyUI and Tailwind CSS
- **Reusable components** for pagination and forms
- **Docker containerization** with automatic database setup and data persistence
- **Docker profiles** for different configurations (normal, cache, search, all)
- **Cache** with Redis for improved performance
- **Search** with OpenSearch for advanced search
- **Nginx** for reverse proxy and load balancing
