#!/usr/bin/env bash

MASTER_PROJECT_NAME="master-project"
PYTHON_VERSION="3.12.11"
DJANGO_PROJECT_NAME="myproject"
DB_NAME="myproject"
DB_USER="admin"
DB_PASS="admin"
VIRTUAL_ENV=".venv"

read -p "Enter MASTER_PROJECT_NAME (default: master-project): " MASTER_PROJECT_NAME
MASTER_PROJECT_NAME=${MASTER_PROJECT_NAME:-"master-project"}

read -p "Enter PYTHON_VERSION (default: 3.12.11): " PYTHON_VERSION
PYTHON_VERSION=${PYTHON_VERSION:-"3.12.11"}

read -p "Enter DJANGO_PROJECT_NAME (default: myproject - should be named as a python module): " DJANGO_PROJECT_NAME
DJANGO_PROJECT_NAME=${DJANGO_PROJECT_NAME:-"myproject"}

read -p "Enter DB_NAME (default: myproject): " DB_NAME
DB_NAME=${DB_NAME:-"myproject"}

read -p "Enter DB_USER (default: admin): " DB_USER
DB_USER=${DB_USER:-"admin"}

read -p "Enter DB_PASS (default: admin): " DB_PASS
DB_PASS=${DB_PASS:-"admin"}

read -p "Enter VIRTUAL_ENV (default: .venv): " VIRTUAL_ENV
VIRTUAL_ENV=${VIRTUAL_ENV:-".venv"}

# clear; reset;

function create_master_project() {
    echo "Re-creating $MASTER_PROJECT_NAME if exists ..."
    rm -rf $MASTER_PROJECT_NAME
    mkdir $MASTER_PROJECT_NAME
    echo "  Done"
}

function set_runtime() {
    pyenv install -s $PYTHON_VERSION
    echo "Setting runtime ..."
    echo "python-$PYTHON_VERSION" > runtime.txt
    echo "  Done"
}

function build_virtual_env() {
    echo "Building virtual environment ..."
    if python -m venv --copies $VIRTUAL_ENV; then
        source $VIRTUAL_ENV/bin/activate
        echo "  Done"
    else
        echo "  Error: Failed to create the virtual environment."
        exit 1
    fi
}

function setup_poetry() {
    echo "Setting up Poetry ..."
    if pip install poetry; then
        echo "  Done"
    else
        echo "  Error: Failed to install Poetry."
        exit 1
    fi

    poetry init --no-interaction --name=$DJANGO_PROJECT_NAME  --author=admin@example.org --python=">=3.12,<4"

    echo "Adding dependencies to Poetry ..."
    poetry add django \
        psycopg2-binary \
        gunicorn \
        django-environ \
        django-unfold \
        django-widget-tweaks

    poetry add --group dev black \
        coverage \
        flake8 \
        pip-audit \
        pip-tools \
        poetry \
        poetry-plugin-export \
        pre-commit \
        djlint

    echo "Adding tool configurations to pyproject.toml ..."
    cat >> pyproject.toml << 'EOF'

[tool.poetry.group.dev.dependencies]
black = "^25.1.0"
coverage = "^7.10.6"
flake8 = "^7.3.0"
pip-audit = "^2.9.0"
pip-tools = "^7.5.0"
poetry = "^2.1.4"
poetry-plugin-export = "^1.9.0"
pre-commit = "^4.3.0"
djlint = "^1.36.4"

[tool.black]
line-length = 88
target-version = ['py312']
include = '\.pyi?$'
extend-exclude = '''
/(
  # directories
  \.eggs
  | \.git
  | \.hg
  | \.mypy_cache
  | \.tox
  | \.venv
  | build
  | dist
  | migrations
)/
'''
# Custom spacing - Black handles this through its default behavior
# One-liners stay together, multi-line statements get spaced
skip-string-normalization = false
EOF
    echo "  Done"
    poetry lock
}


function create_django_project() {
    echo "Setting up Django project ..."
    django-admin startproject $DJANGO_PROJECT_NAME &&
    echo "  Done"
}

function set_config_dir() {
    echo "Setting up config directory ..."
    echo "We are in $(pwd)"
    mkdir $DJANGO_PROJECT_NAME/config
    mv $DJANGO_PROJECT_NAME/$DJANGO_PROJECT_NAME/settings.py $DJANGO_PROJECT_NAME/config/.
    mv $DJANGO_PROJECT_NAME/$DJANGO_PROJECT_NAME/urls.py $DJANGO_PROJECT_NAME/config/.
    mv $DJANGO_PROJECT_NAME/$DJANGO_PROJECT_NAME/wsgi.py $DJANGO_PROJECT_NAME/config/.
    mv $DJANGO_PROJECT_NAME/$DJANGO_PROJECT_NAME/asgi.py $DJANGO_PROJECT_NAME/config/.

    rm -rf $DJANGO_PROJECT_NAME/$DJANGO_PROJECT_NAME

    # Update import paths after restructuring
    sed "s/$DJANGO_PROJECT_NAME\./config\./g" $DJANGO_PROJECT_NAME/manage.py > temp_file && mv temp_file $DJANGO_PROJECT_NAME/manage.py
    sed "s/$DJANGO_PROJECT_NAME\./config\./g" $DJANGO_PROJECT_NAME/config/wsgi.py > temp_file && mv temp_file $DJANGO_PROJECT_NAME/config/wsgi.py
    sed "s/$DJANGO_PROJECT_NAME\./config\./g" $DJANGO_PROJECT_NAME/config/asgi.py > temp_file && mv temp_file $DJANGO_PROJECT_NAME/config/asgi.py
    sed "s/$DJANGO_PROJECT_NAME\./config\./g" $DJANGO_PROJECT_NAME/config/settings.py > temp_file && mv temp_file $DJANGO_PROJECT_NAME/config/settings.py

    # Skip setadminpw.py and docker-compose files that don't exist yet
    if [ -f "$DJANGO_PROJECT_NAME/setadminpw.py" ]; then
        sed "s/$DJANGO_PROJECT_NAME\./config\./g" $DJANGO_PROJECT_NAME/setadminpw.py > temp_file && mv temp_file $DJANGO_PROJECT_NAME/setadminpw.py
    fi

    if [ -f "docker-compose.prod.yml" ]; then
        sed "s/$DJANGO_PROJECT_NAME\./config\./g" docker-compose.prod.yml > temp_file && mv temp_file docker-compose.prod.yml
    fi

    echo "  Done"
}

function add_env_files() {
    echo "Adding environment files ..."
    sed "s/\$DB_NAME/${DB_NAME}/g" ../files/.env.dev > .env.dev
    sed "s/\$DB_USER/${DB_USER}/g" .env.dev > .env.dev.tmp
    mv .env.dev.tmp .env.dev
    sed "s/\$DB_PASS/${DB_PASS}/g" .env.dev > .env.dev.tmp
    mv .env.dev.tmp .env.dev

    sed "s/\$DB_NAME/${DB_NAME}/g" ../files/.env.prod > .env.prod
    sed "s/\$DB_USER/${DB_USER}/g" .env.prod > .env.prod.tmp
    mv .env.prod.tmp .env.prod
    sed "s/\$DB_PASS/${DB_PASS}/g" .env.prod > .env.prod.tmp
    mv .env.prod.tmp .env.prod
    
    sed "s/\$DB_NAME/${DB_NAME}/g" ../files/.env.prod.db > .env.prod.db
    sed "s/\$DB_USER/${DB_USER}/g" .env.prod.db > .env.prod.db.tmp
    mv .env.prod.db.tmp .env.prod.db
    sed "s/\$DB_PASS/${DB_PASS}/g" .env.prod.db > .env.prod.db.tmp
    mv .env.prod.db.tmp .env.prod.db
    echo "  Done"
}

function add_docker_files() {
    echo "Adding docker-compose files ..."
    sed "s/\$DJANGO_PROJECT_NAME/$DJANGO_PROJECT_NAME/g" ../files/docker-compose.yml > ./docker-compose.yml
    sed "s/\$DJANGO_PROJECT_NAME/$DJANGO_PROJECT_NAME/g" ../files/docker-compose.prod.yml > ./docker-compose.prod.yml
    sed "s/\$DB_NAME/$DB_NAME/g" ../files/docker-compose.yml > ./docker-compose.yml
    sed "s/\$DB_NAME/$DB_NAME/g" ../files/docker-compose.prod.yml > ./docker-compose.prod.yml
    echo "  Done"

    echo "Adding Dockerfiles ..."
    sed "s/\$DJANGO_PROJECT_NAME/$DJANGO_PROJECT_NAME/g" ../files/Dockerfile > $DJANGO_PROJECT_NAME/Dockerfile
    sed "s/\$DJANGO_PROJECT_NAME/$DJANGO_PROJECT_NAME/g" ../files/Dockerfile.prod > $DJANGO_PROJECT_NAME/Dockerfile.prod
    echo "  Done"

    echo "Adding entrypoint files ..."
    cp ../files/entrypoint.* $DJANGO_PROJECT_NAME/.
    echo "  Done"
}

function setup_nginx() {
    echo "Setting up Nginx ..."
    mkdir nginx
    cp ../files/nginx/Dockerfile nginx/.
    sed "s/\$DJANGO_PROJECT_NAME/$DJANGO_PROJECT_NAME/g" ../files/nginx/nginx.conf > nginx/nginx.conf
    echo "  Done"
}

function add_scripts() {
    echo "Additional scripts ..."
    cp ../files/createadmin.sh $DJANGO_PROJECT_NAME/.
    sed "s/\$DJANGO_PROJECT_NAME/$DJANGO_PROJECT_NAME/g" ../files/setadminpw.py > $DJANGO_PROJECT_NAME/setadminpw.py
    cp ../files/dev-up.sh .
    sed "s/\$DJANGO_PROJECT_NAME/$DJANGO_PROJECT_NAME/g" ../files/dev-up.sh > ./dev-up.sh
    cp ../files/prod-up.sh .
    sed "s/\$DJANGO_PROJECT_NAME/$DJANGO_PROJECT_NAME/g" ../files/prod-up.sh > ./prod-up.sh
    cp ../files/test.sh $DJANGO_PROJECT_NAME/.
    chmod +x $DJANGO_PROJECT_NAME/test.sh
    cp ../files/.gitignore .
    cp .env.dev $DJANGO_PROJECT_NAME/.env
    sed "s/\$DJANGO_PROJECT_NAME/$DJANGO_PROJECT_NAME/g" ../files/pre-commit-config.yaml > ./.pre-commit-config.yaml
    cp ../files/.isort.cfg $DJANGO_PROJECT_NAME/.isort.cfg
    cp ../files/.djlintrc $DJANGO_PROJECT_NAME/.djlintrc
    cp ../files/.prettierrc $DJANGO_PROJECT_NAME/.prettierrc
    cp ../files/.flake8 $DJANGO_PROJECT_NAME/.flake8
    echo "  Done"
}

function add_folders() {
    mkdir $DJANGO_PROJECT_NAME/staticfiles
    mkdir $DJANGO_PROJECT_NAME/static
    mkdir $DJANGO_PROJECT_NAME/mediafiles
    mkdir $DJANGO_PROJECT_NAME/apps
    touch $DJANGO_PROJECT_NAME/apps/__init__.py
    cp -rf $VIRTUAL_ENV/**/**/site-packages/django/contrib/admin/static/admin $DJANGO_PROJECT_NAME/static/.
}

function add_django_settings() {
    sed "s/\$DJANGO_PROJECT_NAME/$DJANGO_PROJECT_NAME/g" ../files/settings.py > $DJANGO_PROJECT_NAME/config/settings.py
    echo "  Done"
}

function setup_tailwind() {
    cp -rf ../files/tailwind .
    sed "s/\$DJANGO_PROJECT_NAME/$DJANGO_PROJECT_NAME/g" ../files/tailwind/package.json > tailwind/package.json
    sed "s/\$DJANGO_PROJECT_NAME/$DJANGO_PROJECT_NAME/g" ../files/tailwind/tailwind.config.js > tailwind/tailwind.config.js
    cd tailwind
    npm install
    cd ..
    echo "  Done"
}

function show_directions() {
    echo "Your Django project $MASTER_PROJECT_NAME should be set up with docker."
    echo "Now, cd into " $MASTER_PROJECT_NAME
    echo "Run source $VIRTUAL_ENV/bin/activate"
    echo "And then run either (sudo) ./dev-up.sh or (sudo) ./prod-up.sh"
}

create_master_project;
cd $MASTER_PROJECT_NAME &&
set_runtime;
build_virtual_env;
setup_poetry;
create_django_project;
set_config_dir
add_env_files &&
add_docker_files &&
setup_nginx;
add_scripts &&
add_folders &&
add_django_settings &&
setup_tailwind &&
show_directions;
