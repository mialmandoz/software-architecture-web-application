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

# Build and start the application with Docker
docker-compose up --build
```

The application will be available at: **http://localhost:4000**

### Important:
If the error: 
```
(Phoenix.Router.NoRouteError) no route found for GET /assets/css/app.css (WebApplicationWeb.Router)
```
appears:

Close the website and restart docker:

**-> Ctrl+C -> docker-compose up --build**

And open the website again

---

**Data Persistence**: Your database data automatically persists between container restarts. The PostgreSQL data is stored in a Docker volume, so you can safely stop and restart containers without losing your books, authors, reviews, and sales data.

---

## 3. Project Structure

```
web_application/
├── lib/                           # Main application code
│   ├── web_application/           # Business logic and contexts
│   │   ├── application.ex         # Application configuration
│   │   ├── repo.ex               # Ecto repository
│   │   ├── mailer.ex             # Email configuration
│   │   ├── data_generator.ex     # Test data generator
│   │   ├── authors/              # Authors context
│   │   │   └── author.ex         # Schema and validations
│   │   ├── authors.ex            # CRUD functions for authors
│   │   ├── books/                # Books context
│   │   │   └── book.ex           # Schema and validations
│   │   ├── books.ex              # CRUD functions for books (with filters)
│   │   ├── reviews/              # Reviews context
│   │   │   └── review.ex         # Schema and validations
│   │   ├── reviews.ex            # CRUD functions for reviews
│   │   ├── sales/                # Sales context
│   │   │   └── sale.ex           # Schema and validations
│   │   └── sales.ex              # CRUD functions for sales
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
│   │   │   │   ├── show.html.heex      # Book detail
│   │   │   │   ├── new.html.heex       # Create book
│   │   │   │   ├── edit.html.heex      # Edit book
│   │   │   │   └── book_form.html.heex # Form
│   │   │   ├── book_html.ex            # View helpers
│   │   │   ├── review_controller.ex    # Reviews CRUD
│   │   │   ├── review_html/            # Reviews HTML views
│   │   │   │   ├── index.html.heex     # List with pagination
│   │   │   │   ├── show.html.heex      # Review detail
│   │   │   │   ├── new.html.heex       # Create review
│   │   │   │   ├── edit.html.heex      # Edit review
│   │   │   │   └── review_form.html.heex # Form
│   │   │   ├── review_html.ex          # View helpers
│   │   │   ├── sale_controller.ex      # Sales CRUD
│   │   │   ├── sale_html/              # Sales HTML views
│   │   │   │   ├── index.html.heex     # List with pagination
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
│   │   └── app.css                   # Main styles
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
│   │   │   └── 20250812201612_create_sales.exs
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
├── .formatter.exs                   # Formatter configuration
├── .gitignore                       # Files ignored by Git
├── AGENTS.md                        # Agents documentation
├── Dockerfile                       # Docker container configuration
├── README.md                        # This file
├── docker-compose.yml               # PostgreSQL configuration
├── mix.exs                          # Project dependencies and configuration
└── mix.lock                         # Exact dependency versions
```

### Implemented Features

- **Complete CRUD** for Authors, Books, Reviews and Sales
- **Pagination** in all index views (10 items per page)
- **Search filters** in books (by title, author and description)
- **Entity relationships** (books-authors, reviews-books, etc.)
- **Validations** in all forms
- **Modern interface** with DaisyUI and Tailwind CSS
- **Reusable components** for pagination and forms
- **Docker containerization** with automatic database setup and data persistence

---

## 4. Useful Resources

- [Phoenix Framework](https://hexdocs.pm/phoenix)
- [Elixir](https://elixir-lang.org/docs.html)
- [Ecto ORM](https://hexdocs.pm/ecto)
- [Docker Compose](https://docs.docker.com/compose/)
