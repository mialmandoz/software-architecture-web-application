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

### Image Upload Configuration

The application supports comprehensive image uploads for book covers and author profile images with advanced configuration options.

### ✨ Features

- **📚 Book Cover Images**: Upload and display cover images for books
- **👤 Author Profile Images**: Upload and display profile photos for authors
- **🔒 File Validation**: Supports JPEG, PNG, GIF, and WebP formats with 5MB size limit
- **⚙️ Configurable Storage**: Customizable storage path via environment variables
- **🌐 Reverse Proxy Support**: Static asset serving can be disabled for production deployments
- **🧹 Automatic Cleanup**: Old images are automatically deleted when updated or records are deleted
- **🎨 Elegant UI**: Beautiful fallback placeholders when no image is present
- **📱 Responsive Design**: Images display properly across all device sizes

### 🛠️ Configuration Options

#### Storage Path Customization

```bash
# Default: priv/static/uploads
export UPLOADS_PATH="/custom/upload/directory"
```

#### Reverse Proxy Configuration

```bash
# Disable Phoenix static serving when using Nginx/Apache (default: true)
export SERVE_STATIC_ASSETS=false

# Complete reverse proxy setup example:
export UPLOADS_PATH="/var/www/uploads"
export SERVE_STATIC_ASSETS=false
docker-compose --profile nginx up --build
```

**Profile Recommendations for Image Upload Testing:**

- **Basic testing**: Use `--profile normal` (sufficient for all image upload features)
- **Production testing**: Use `--profile nginx` to test reverse proxy static asset serving

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

### 📁 File Organization

```
uploads/
├── book_cover/              # Book cover images
│   ├── book_cover_1693934400_a1b2c3d4.jpg
│   └── book_cover_1693934500_e5f6g7h8.png
└── author_profile/          # Author profile images
    ├── author_profile_1693934600_i9j0k1l2.jpg
    └── author_profile_1693934700_m3n4o5p6.webp
```

### 🎯 Usage Guide

#### Uploading Images

1. **Navigate** to any book or author form (New/Edit)
2. **Select** an image using the file input field
3. **Validation** happens automatically (type, size, format)
4. **Upload** completes when you save the form
5. **Display** images appear immediately in listings and detail pages

#### Image Display Locations

- **📋 Book Index**: Small cover thumbnails (48×64px) in table rows
- **📖 Book Detail**: Large cover display (192×256px) prominently featured
- **👥 Author Index**: Circular profile avatars (48×48px) in table rows
- **👤 Author Detail**: Large circular profile image (192×192px) centered
- **🔄 Edit Forms**: Current image preview with upload option for replacement

#### File Validation Rules

- **📎 Formats**: JPEG, PNG, GIF, WebP only
- **📏 Size Limit**: Maximum 5MB per file
- **🔍 Extension Check**: Validates both MIME type and file extension
- **⚡ Unique Names**: Auto-generated filenames prevent conflicts

### 🔧 Technical Implementation

#### Backend Components

- **`WebApplication.FileUpload`**: Core upload handling module
- **Database Fields**: `cover_image_url` (books), `profile_image_url` (authors)
- **Controller Integration**: Automatic processing in create/update actions
- **Cleanup Logic**: Automatic deletion of old files on update/delete

#### Frontend Features

- **Multipart Forms**: Proper form encoding for file uploads
- **Preview Display**: Shows current images in edit forms
- **Fallback UI**: Elegant placeholders with icons when no image present
- **Responsive Images**: Proper aspect ratios and mobile-friendly display

#### Security & Performance

- **File Validation**: Multiple layers of type and size checking
- **Unique Filenames**: `{type}_{timestamp}_{random_hash}.{ext}` format
- **Error Handling**: Graceful fallbacks when uploads fail
- **Static Serving**: Configurable for optimal production performance

### 🧪 Testing Recommendations

**For Basic Testing:**

```bash
docker-compose --profile normal up --build
# Test all upload features at http://localhost:4000
```

**For Production Testing:**

```bash
export SERVE_STATIC_ASSETS=false
docker-compose --profile nginx up --build
# Test reverse proxy serving at http://localhost:80
```

The image upload system integrates seamlessly with all existing features including caching, search, and pagination.

---

## 3. Load Testing

The application includes a comprehensive Gatling-based load testing framework to evaluate performance across all deployment configurations.

### Quick Start

**Run all tests (comprehensive suite - ~3-4 hours):**

```bash
cd load-testing
chmod +x run-tests.sh
./run-tests.sh
```

**Run quick tests for specific profiles:**

```bash
cd load-testing
chmod +x quick-test.sh
# Run the correponding docker-compose profile first
# e.g. docker-compose --profile normal up --build
./quick-test.sh normal 100 5     # Test normal profile with 100 users for 5 minutes
./quick-test.sh cache 1000 5    # Test cache profile with 1000 users for 5 minutes
./quick-test.sh search 50 5      # Test search profile with 50 users for 5 minutes
./quick-test.sh nginx-normal 500 5     # Test nginx profile with 500 users for 5 minutes
./quick-test.sh all 200 5       # Test all features with 200 users for 5 minutes
```

### Test Scenarios

The load tests simulate realistic user behavior with the following distribution:

- **Browse Books** (40%) - Users browsing the book catalog
- **Search Books** (25%) - Users performing book searches
- **Browse Authors** (15%) - Users viewing author profiles
- **Browse Reviews** (15%) - Users reading book reviews
- **Browse Sales** (5%) - Users checking sales data

### Monitoring

**Basic monitoring (included by default):**

- Response times and success rates
- Container resource usage (CPU, memory, network, I/O)
- Automated stats collection during tests

### Results

Test results are automatically saved to:

- **HTML Reports:** `load-testing/results/[profile]/[timestamp]/`
- **Container Stats:** `load-testing/stats/[profile]_[users]users_[timestamp].txt`

For detailed documentation, see [`load-testing/README.md`](load-testing/README.md).

---

## 4. Troubleshooting

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

## 4. Cache Implementation

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

## 5. Project Structure

```
web_application/
├── lib/                           # Main application code
│   ├── web_application/           # Business logic and contexts
│   │   ├── application.ex         # Application configuration
│   │   ├── repo.ex               # Ecto repository
│   │   ├── mailer.ex             # Email configuration
│   │   ├── cache.ex              # Redis/In-memory cache module
│   │   ├── search.ex             # OpenSearch integration for full-text search
│   │   ├── file_upload.ex        # Image upload handling module
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
│   │   │   ├── author_controller.ex    # Authors CRUD with image upload
│   │   │   ├── author_html/            # Authors HTML views
│   │   │   │   ├── index.html.heex     # List with pagination and images
│   │   │   │   ├── show.html.heex      # Author detail with profile image
│   │   │   │   ├── new.html.heex       # Create author
│   │   │   │   ├── edit.html.heex      # Edit author
│   │   │   │   └── author_form.html.heex # Form with image upload
│   │   │   ├── author_html.ex          # View helpers
│   │   │   ├── book_controller.ex      # Books CRUD with image upload
│   │   │   ├── book_html/              # Books HTML views
│   │   │   │   ├── index.html.heex     # List with filters, pagination and cover images
│   │   │   │   ├── search.html.heex    # Advanced search interface
│   │   │   │   ├── show.html.heex      # Book detail with cover image
│   │   │   │   ├── new.html.heex       # Create book
│   │   │   │   ├── edit.html.heex      # Edit book
│   │   │   │   └── book_form.html.heex # Form with image upload
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
│   │   │   ├── 20250816192744_update_author_books_cascade_delete.exs
│   │   │   └── 20250906224606_add_image_fields_to_books_and_authors.exs
│   │   └── seeds.exs                # Initial data
│   └── static/                      # Static files
│       ├── images/                  # Images
│       ├── uploads/                 # User uploaded images
│       │   ├── book_cover/          # Book cover images
│       │   └── author_profile/      # Author profile images
│       ├── favicon.ico              # Site icon
│       └── robots.txt               # Robots configuration
├── test/                            # Automated tests
│   ├── support/                     # Test support
│   │   ├── conn_case.ex            # Connection test cases
│   │   └── data_case.ex            # Data test cases
│   ├── web_application_web/         # Web tests
│   │   └── controllers/             # Controller tests
│   └── test_helper.exs              # Test configuration
├── load-testing/                    # Performance testing framework
│   ├── simulations/                 # Gatling test simulations
│   │   └── WebApplicationLoadTest.scala # Main load test with realistic user scenarios
│   ├── monitoring/                  # Monitoring configuration
│   │   └── prometheus.yml          # Prometheus metrics collection setup
│   ├── README.md                   # Load testing documentation and usage guide
│   ├── docker-compose.gatling.yml  # Gatling and monitoring services configuration
│   ├── run-tests.sh               # Automated test suite for all profiles and load levels
│   └── quick-test.sh              # Quick testing script for individual profiles
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

---

## 6. Useful Resources

- [Phoenix Framework](https://hexdocs.pm/phoenix)
- [Elixir](https://elixir-lang.org/docs.html)
- [Ecto ORM](https://hexdocs.pm/ecto)
- [Docker Compose](https://docs.docker.com/compose/)

---

## 7. Implemented Features

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
