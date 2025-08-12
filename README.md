# WebApplication

Aplicación web desarrollada con **Phoenix Framework** y **PostgreSQL**.

---

## 1. Requisitos

### macOS

```bash
# Instalar Homebrew (si no lo tienes)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Instalar Elixir y Erlang
brew install elixir

# Instalar Docker Desktop
brew install --cask docker

# (Opcional) Instalar Node.js si se requieren herramientas npm
brew install node
```

### Linux (Ubuntu/Debian)

```bash
# Actualizar el sistema
sudo apt update

# Instalar Erlang y Elixir
wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
sudo dpkg -i erlang-solutions_2.0_all.deb
sudo apt update
sudo apt install esl-erlang elixir

# Instalar Docker
sudo apt install docker.io docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# (Opcional) Instalar Node.js
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
```

### Windows

1. **Instalar Erlang y Elixir:** https://elixir-lang.org/install.html#windows
2. **Instalar Docker Desktop:** https://www.docker.com/products/docker-desktop
3. **(Opcional) Instalar Node.js:** https://nodejs.org/
4. **Instalar Git:** https://git-scm.com/

---

## 2. Instalación del proyecto

```bash
# Clonar el repositorio
git clone https://github.com/mialmandoz/software-architecture-web-application
cd software-architecture-web-application

# Instalar herramientas de Phoenix
mix local.hex --force
mix archive.install hex phx_new --force

# Instalar dependencias
mix deps.get
mix assets.setup
```

---

## 3. Configuración de la base de datos

```bash
# Iniciar PostgreSQL con Docker
docker-compose up -d
docker ps  # Verificar que está corriendo

# Crear, migrar y poblar la base de datos
mix ecto.create
mix ecto.migrate
mix run priv/repo/seeds.exs

# Resetear y poblar la base de datos
mix ecto.reset
```

---

## 4. Ejecución de la aplicación

```bash
# Iniciar servidor
mix phx.server

# O en modo interactivo
iex -S mix phx.server
```

La aplicación estará disponible en: **http://localhost:4000** (modo desarrollo)

---

## 5. Comandos útiles

### Entorno y servidor
```bash
docker-compose up -d       # Iniciar PostgreSQL
docker-compose down        # Detener PostgreSQL
mix phx.server             # Iniciar aplicación
```

### Desarrollo
```bash
mix test                   # Ejecutar tests
mix format                 # Formatear código
mix phx.routes             # Listar rutas
```

### Base de datos
```bash
mix ecto.gen.migration nombre_migracion  # Nueva migración
mix ecto.migrate                         # Ejecutar migraciones
mix ecto.rollback                        # Revertir última migración
mix ecto.reset                           # Resetear base
```

### Docker
```bash
docker ps                 # Ver contenedores activos
docker-compose logs db    # Ver logs de PostgreSQL
docker-compose restart db # Reiniciar PostgreSQL
```

---

## 6. Solución de problemas

### Error de conexión a base de datos
```bash
docker ps
docker-compose restart db
docker-compose logs db
```

### Error de dependencias
```bash
mix deps.clean --all
mix deps.get
mix deps.compile
```

### Puerto 4000 ocupado
```bash
lsof -ti:4000 | xargs kill -9
```

---

## 7. Estructura del proyecto

```
web_application/
├── lib/                    # Código principal de la aplicación
│   ├── web_application/    # Lógica de negocio
│   └── web_application_web/ # Controladores, vistas, etc.
├── assets/                 # CSS, JavaScript, imágenes
├── config/                 # Configuración
├── priv/                   # Migraciones y archivos estáticos
├── test/                   # Pruebas
├── docker-compose.yml      # Configuración de PostgreSQL
└── mix.exs                 # Dependencias y configuración
```

---

## 8. Recursos útiles

- [Phoenix Framework](https://hexdocs.pm/phoenix)
- [Elixir](https://elixir-lang.org/docs.html)
- [Ecto ORM](https://hexdocs.pm/ecto)
- [Docker Compose](https://docs.docker.com/compose/)

---

