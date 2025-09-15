# Django-Dockerize

A streamlined tool for bootstrapping Django projects with complete Docker containerization. Get from zero to a production-ready Django application in minutes.

## 🚀 Overview

Django-Dockerize automates the creation of a fully containerized Django project with separate development and production environments. It provides everything you need to start building Django applications with modern deployment practices.

### ✨ What You Get

- **Complete Django project** with Docker containerization
- **Development environment** with hot-reload and debugging support
- **Production environment** with Nginx reverse proxy and Gunicorn WSGI server
- **PostgreSQL database** with persistent volumes
- **Code quality tools** including Black formatter, pre-commit hooks, and linting
- **Testing setup** with coverage reporting
- **Admin user creation** with convenient scripts
- **Environment management** using django-environ

### 🎯 When to Use This

Perfect for:
- Setting up new Django projects quickly
- Learning Django with Docker
- Production deployments using containers (Kubernetes, Docker Swarm)
- Teams wanting consistent development environments
- Projects requiring PostgreSQL from day one

**Not Opinionated**: Unlike heavyweight alternatives like [cookiecutter-django](https://github.com/cookiecutter/cookiecutter-django), this tool provides a minimal foundation that you can customize as needed.

## 📋 Prerequisites

- **Python 3.12+** (managed via pyenv recommended)
- **Docker** and **Docker Compose**
- **Git**

## 🛠 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/hseritt/django-dockerize.git
cd django-dockerize
```

### 2. Run the Setup Script

```bash
./dockerize.sh
```

### 3. Configure Your Project

You'll be prompted for configuration details:

```
Enter MASTER_PROJECT_NAME (default: master-project): my-awesome-project
Enter PYTHON_VERSION (default: 3.12.11): 3.12.11
Enter DJANGO_PROJECT_NAME (default: myproject): myapp
Enter DB_NAME (default: myproject): myapp_db
Enter DB_USER (default: admin): dbuser
Enter DB_PASS (default: admin): secure_password
Enter VIRTUAL_ENV (default: .venv): .venv
```

### 4. Start Development

```bash
cd my-awesome-project  # Your chosen project name
./dev-up.sh           # Start development environment
```

Your Django application will be available at: http://localhost:8000

## 📁 Project Structure

After running the setup, you'll get:

```
my-awesome-project/
├── myapp/                          # Django project directory
│   ├── config/                     # Django settings
│   ├── static/                     # Static files
│   ├── templates/                  # HTML templates
│   ├── Dockerfile                  # Development container
│   ├── Dockerfile.prod            # Production container
│   ├── manage.py                   # Django management
│   └── requirements.txt           # Python dependencies
├── docker-compose.yml             # Development services
├── docker-compose.prod.yml        # Production services
├── .env.dev                       # Development environment
├── .env.prod                      # Production environment
├── dev-up.sh                      # Start development
├── prod-up.sh                     # Start production
├── test.sh                        # Run tests
└── .venv/                         # Python virtual environment
```

## 🔧 Available Scripts

### Development
- `./dev-up.sh` - Start development environment with hot-reload
- `./test.sh` - Run tests with coverage reporting
- `./createadmin.sh` - Create Django superuser (admin/admin)
- `./clear_pyc.sh` - Clean Python cache files

### Production
- `./prod-up.sh` - Start production environment with Nginx + Gunicorn

### Database Access
- **Development**: `localhost:6543` (PostgreSQL)
- **Production**: Internal container networking

## 🐳 Docker Services

### Development Environment
- **web**: Django development server (port 8000)
- **db**: PostgreSQL 16 (port 6543)
- **ollama** (optional): AI model service (port 11435)

### Production Environment
- **web**: Gunicorn WSGI server
- **nginx**: Reverse proxy and static file serving
- **db**: PostgreSQL 16 with persistent volumes

## 🔐 Environment Configuration

### Development (.env.dev)
```env
DEBUG=1
SECRET_KEY=your-dev-secret-key
DJANGO_ALLOWED_HOSTS=localhost 127.0.0.1 [::1]
SQL_ENGINE=django.db.backends.postgresql
SQL_DATABASE=myapp_db
SQL_USER=dbuser
SQL_PASSWORD=secure_password
SQL_HOST=db
SQL_PORT=5432
```

### Production (.env.prod)
```env
DEBUG=0
SECRET_KEY=your-production-secret-key
DJANGO_ALLOWED_HOSTS=yourdomain.com
SQL_ENGINE=django.db.backends.postgresql
# ... database settings
```

## 🧪 Testing & Code Quality

### Run Tests
```bash
./test.sh
```

### Pre-commit Hooks
The project includes pre-commit hooks for:
- Code formatting (Black)
- Import sorting (isort)
- Linting (flake8)
- Django checks

### Manual Code Formatting
```bash
# Inside the container or virtual environment
black .
isort .
flake8 .
```

## 🚀 Deployment

### Local Production Testing
```bash
./prod-up.sh
```

### Container Orchestration
The generated Docker files are ready for:
- **Kubernetes** deployments
- **Docker Swarm** clusters
- **Cloud container services** (AWS ECS, Google Cloud Run, etc.)

## 🔧 Customization

### Adding Dependencies
1. Edit `requirements.in`
2. Run `pip-compile requirements.in`
3. Rebuild containers: `docker-compose build`

### Database Changes
- Modify database settings in `.env.dev` or `.env.prod`
- Update `docker-compose.yml` service configuration

### Adding Services
- Edit `docker-compose.yml` to add Redis, Celery, etc.
- Update Django settings accordingly

## 🆚 Included Technologies

- **Django 5.x** - Web framework
- **PostgreSQL 16** - Database
- **Gunicorn** - WSGI server (production)
- **Nginx** - Reverse proxy (production)
- **django-environ** - Environment variable management
- **Black** - Code formatter
- **Pre-commit** - Git hooks for code quality
- **Coverage.py** - Test coverage reporting

## 🤝 Contributing

This project is designed to be minimal and extensible. Contributions that maintain simplicity while adding value are welcome.

## 📝 License

This project is open source. Check the repository for license details.

## 🔗 Alternatives

For more feature-rich Django project templates, consider:
- [cookiecutter-django](https://github.com/cookiecutter/cookiecutter-django) - Full-featured with many integrations
- [django-admin startproject](https://docs.djangoproject.com/en/stable/ref/django-admin/#startproject) - Minimal Django setup
