#!/usr/bin/env bash

MASTER_PROJECT_NAME="master-project"
PYTHON_VERSION="3.12.11"
DJANGO_PROJECT_NAME="myproject"
DB_NAME="myproject"
DB_USER="admin"
DB_PASS="admin"

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

# clear; reset;

function create_master_project() {
    echo "Re-creating $MASTER_PROJECT_NAME if exists ..."
    rm -rf $MASTER_PROJECT_NAME
    mkdir $MASTER_PROJECT_NAME
    cd $MASTER_PROJECT_NAME
    git init
    cd ..
    echo "  Done"
}

function set_runtime() {
    pyenv install -s $PYTHON_VERSION
    echo "Setting runtime ..."
    echo "python-$PYTHON_VERSION" > runtime.txt
    echo "  Done"
}

function setup_uv() {
    echo "Setting up uv ..."
    if ! command -v uv &> /dev/null; then
        echo "  uv not found, installing ..."
        if pip install uv; then
            echo "  uv installed"
        else
            echo "  Error: Failed to install uv."
            exit 1
        fi
    fi

    echo "  Upgrading uv ..."
    if uv self update 2>/dev/null || pip install --upgrade uv; then
        echo "  uv up to date"
    else
        echo "  Warning: Could not upgrade uv. Continuing with existing version."
    fi

    uv init --no-workspace --no-readme --name $DJANGO_PROJECT_NAME --python $PYTHON_VERSION
    rm -f hello.py main.py

    echo "Adding production dependencies ..."
    uv add django \
        psycopg2-binary \
        gunicorn \
        django-environ \
        django-unfold \
        django-widget-tweaks

    echo "Adding development dependencies ..."
    uv add --dev black \
        coverage \
        flake8 \
        pip-audit \
        pre-commit \
        djlint

    echo "Adding tool configurations to pyproject.toml ..."
    cat >> pyproject.toml << 'EOF'

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
skip-string-normalization = false
EOF
    echo "  Done"
}

function export_requirements() {
    echo "Exporting requirements.txt ..."
    uv export --no-hashes --no-dev -o $DJANGO_PROJECT_NAME/requirements.txt
    echo "  Done"
}


function create_django_project() {
    echo "Setting up Django project ..."
    uv run django-admin startproject $DJANGO_PROJECT_NAME &&
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
    sed "s/\$DJANGO_PROJECT_NAME/$DJANGO_PROJECT_NAME/g; s/\$DB_NAME/$DB_NAME/g" ../files/docker-compose.yml > ./docker-compose.yml
    sed "s/\$DJANGO_PROJECT_NAME/$DJANGO_PROJECT_NAME/g; s/\$DB_NAME/$DB_NAME/g" ../files/docker-compose.prod.yml > ./docker-compose.prod.yml
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
    DJANGO_ADMIN_STATIC=$(uv run python -c "import django, os; print(os.path.join(os.path.dirname(django.__file__), 'contrib/admin/static/admin'))")
    cp -rf "$DJANGO_ADMIN_STATIC" $DJANGO_PROJECT_NAME/static/.
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
    echo "Now, cd into $MASTER_PROJECT_NAME"
    echo "And then run either (sudo) ./dev-up.sh or (sudo) ./prod-up.sh"
    echo "To run management commands locally, use: uv run python manage.py <command>"
}

create_master_project;
cd $MASTER_PROJECT_NAME &&
set_runtime;
setup_uv;
create_django_project;
export_requirements;
set_config_dir
add_env_files &&
add_docker_files &&
setup_nginx;
add_scripts &&
add_folders &&
add_django_settings &&
setup_tailwind &&
show_directions;
