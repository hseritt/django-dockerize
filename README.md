# Dockerize

Dockerize allows you to create a Django project and then containerize it with a dev and prod environment (uses nginx and gunicorn). It also sets up a Postgresql database.

## How to Use It

Copy the dockerize.sh script along wit the files directory (no need to include the files_static, it won't hurt but you won't need it).

Make any changes to the top of dockerize.sh:

```
# Whatever you want to call the main project folder
MASTER_PROJECT_NAME="master-project"

# The python version you would like to use. Keep in mind
# this script won't install it for you. Use pyenv for that :-P
PYTHON_VERSION="3.10.8"

# Your Django project name. This will be created by the script.
DJANGO_PROJECT_NAME="myproject"

# The database name
DB_NAME="myproject"

# The database user
DB_USER="admin"

# The database password
DB_PASS="admin"
```

Run dockerize:

```
./dockerize.sh
```

## Modify Project to Use Environment Variables

Consider changing these parts in your project settings file to take advantage of the .env files:

```
SECRET_KEY = os.environ.get("SECRET_KEY")

DEBUG = int(os.environ.get("DEBUG", default=0))

# 'DJANGO_ALLOWED_HOSTS' should be a single string of hosts with a space between each.
# For example: 'DJANGO_ALLOWED_HOSTS=localhost 127.0.0.1 [::1]'
ALLOWED_HOSTS = os.environ.get("DJANGO_ALLOWED_HOSTS").split(" ")

...

DATABASES = {
    "default": {
        "ENGINE": os.environ.get("SQL_ENGINE", "django.db.backends.sqlite3"),
        "NAME": os.environ.get("SQL_DATABASE", BASE_DIR / "db.sqlite3"),
        "USER": os.environ.get("SQL_USER", "user"),
        "PASSWORD": os.environ.get("SQL_PASSWORD", "password"),
        "HOST": os.environ.get("SQL_HOST", "localhost"),
        "PORT": os.environ.get("SQL_PORT", "5432"),
    }
}

```

Also, this can be used with the static and media files setup with Nginx:

```
STATIC_URL = "/static/"
STATIC_ROOT = BASE_DIR / "staticfiles"

MEDIA_URL = "/media/"
MEDIA_ROOT = BASE_DIR / "mediafiles"
```

## Project Setup

Create the master project directory:

```
mkdir test2
cd test2
```

Ensure you have the Python version you want:

```
python --version
```

Set the runtime:

```
vi runtime.txt
```

Add something like:

```
python-3.10.8
```

Set the virtual environment:

```
python -m venv pyenv
source pyenv/bin/activate
```

Install pip-tools:

```
pip install pip-tools
pip install --upgrade pip
touch requirements.in
vi requirements.in
```

Add in django lts level, psycopg2, gunicorn, black, pip-tools like so:

```
django==3.2.16
psycopg2-binary
gunicorn

pip-tools
black
```

Run the following:

```
pip-compile
pip-sync
```

Create the Django project:

```
django-admin startproject myproject
cd myproject
./manage.py startapp myapp
```

Add the following files in the master project directory:

```
touch .env.dev .env.prod .env.prod.db
```

Add to .env.dev:

```
DEBUG=1
SECRET_KEY=foo
DJANGO_ALLOWED_HOSTS=localhost 127.0.0.1 [::1]
SQL_ENGINE=django.db.backends.postgresql
SQL_DATABASE=myproject
SQL_USER=admin
SQL_PASSWORD=admin
SQL_HOST=db
SQL_PORT=5432
DATABASE=postgres
```

Add to .env.prod:

```
DEBUG=0
SECRET_KEY=a_much_better_secret_this_time_change_this
DJANGO_ALLOWED_HOSTS=localhost 127.0.0.1 [::1]
SQL_ENGINE=django.db.backends.postgresql
SQL_DATABASE=myproject
SQL_USER=admin
SQL_PASSWORD=admin
SQL_HOST=db
SQL_PORT=5432
DATABASE=postgres
```

Add to .env.prod.db:

```
POSTGRES_USER=admin
POSTGRES_PASSWORD=admin
POSTGRES_DB=myproject
```

Add the following files in the master project directory:

docker-compose.yml, docker-compose.prod.yml

Add to docker-compose.yml:

```
version: '3.8'

services:
  web:
    build: ./myproject
    command: python manage.py runserver 0.0.0.0:8000
    volumes:
      - ./myproject/:/usr/src/myproject/
    ports:
      - 8000:8000
    env_file:
      - ./.env.dev
    depends_on:
      - db
  db:
    image: postgres:13.0-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data/
    environment:
      - POSTGRES_USER=admin
      - POSTGRES_PASSWORD=admin
      - POSTGRES_DB=myproject
    ports:
        - "6543:5432"

volumes:
  postgres_data:
```

Add to docker-compose.prod.yml:

```
version: '3.8'

services:
  web:
    build:
      context: ./myproject
      dockerfile: Dockerfile.prod
    command: gunicorn myproject.wsgi:application --bind 0.0.0.0:8000
    volumes:
      - static_volume:/home/myproject/web/staticfiles
      - media_volume:/home/myproject/web/mediafiles
    expose:
      - 8000
    env_file:
      - ./.env.prod
    depends_on:
      - db
  db:
    image: postgres:13.0-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data/
    env_file:
      - ./.env.prod.db
  nginx:
    build: ./nginx
    volumes:
      - static_volume:/home/myproject/web/staticfiles
      - media_volume:/home/myproject/web/mediafiles
    ports:
      - 80:80
    depends_on:
      - web

volumes:
  postgres_data:
  static_volume:
  media_volume:
```

Create the following files in myproject:

Dockerfile, Dockerfile.prod, entrypoint.sh, entrypoint.prod.sh

Add the following to Dockerfile:

```
# pull official base image
FROM python:3.10.8-alpine

# set work directory
WORKDIR /usr/src/myproject

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install psycopg2 dependencies
RUN apk update \
    && apk add postgresql-dev gcc python3-dev musl-dev

# install dependencies
RUN pip install --upgrade pip
COPY ./requirements.txt .
RUN pip install -r requirements.txt

# copy entrypoint.sh
COPY ./entrypoint.sh .
RUN sed -i 's/\r$//g' /usr/src/myproject/entrypoint.sh
RUN chmod +x /usr/src/myproject/entrypoint.sh

# copy project
COPY . .

# run entrypoint.sh
ENTRYPOINT ["/usr/src/myproject/entrypoint.sh"]
```

Add the following to Dockerfile.prod:

```
###########
# BUILDER #
###########

# pull official base image
FROM python:3.10.8-alpine as builder

# set work directory
WORKDIR /usr/src/myproject

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install psycopg2 dependencies
RUN apk update \
    && apk add postgresql-dev gcc python3-dev musl-dev

# lint
RUN pip install --upgrade pip
RUN pip install flake8==3.9.2
COPY . .
RUN flake8 --ignore=E501,F401 .

# install dependencies
COPY ./requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /usr/src/myproject/wheels -r requirements.txt


#########
# FINAL #
#########

# pull official base image
FROM python:3.10.8-alpine

# create directory for the app user
RUN mkdir -p /home/myproject

# create the app user
RUN addgroup -S myproject && adduser -S myproject -G myproject

# create the appropriate directories
ENV HOME=/home/myproject
ENV APP_HOME=/home/myproject/web
RUN mkdir $APP_HOME
RUN mkdir $APP_HOME/staticfiles
RUN mkdir $APP_HOME/mediafiles
WORKDIR $APP_HOME

# install dependencies
RUN apk update && apk add libpq
COPY --from=builder /usr/src/myproject/wheels /wheels
COPY --from=builder /usr/src/myproject/requirements.txt .
RUN pip install --no-cache /wheels/*

# copy entrypoint.prod.sh
COPY ./entrypoint.prod.sh .
RUN sed -i 's/\r$//g'  $APP_HOME/entrypoint.prod.sh
RUN chmod +x  $APP_HOME/entrypoint.prod.sh

# copy project
COPY . $APP_HOME

# chown all the files to the app user
RUN chown -R myproject:myproject $APP_HOME

# change to the app user
USER myproject

# run entrypoint.prod.sh
ENTRYPOINT ["/home/myproject/web/entrypoint.prod.sh"]
```

Add the following to entrypoint.sh:

```
#!/bin/sh

if [ "$DATABASE" = "postgres" ]
then
    echo "Waiting for postgres..."

    while ! nc -z $SQL_HOST $SQL_PORT; do
      sleep 0.1
    done

    echo "PostgreSQL started"
fi

python manage.py flush --no-input
python manage.py migrate
sh createadmin.sh
python setadminpw.py

exec "$@"
```

Add the following to entrypoint.prod.sh:

```
#!/bin/sh

if [ "$DATABASE" = "postgres" ]
then
    echo "Waiting for postgres..."

    while ! nc -z $SQL_HOST $SQL_PORT; do
      sleep 0.1
    done

    echo "PostgreSQL started"
fi

exec "$@"
```

Create folder called nginx:

```
mkdir nginx
```

Inside the nginx directory create two files:

Dockerfile, nginx.conf

Add the following to nginx/Dockerfile:

```
FROM nginx:1.21-alpine

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d
```

Add the following to nginx/nginx.conf:

```
upstream myproject {
    server web:8000;
}

server {

    listen 80;

    location / {
        proxy_pass http://myproject;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_redirect off;
    }

    location /static/ {
        alias /home/myproject/web/staticfiles/;
    }

    location /media/ {
        alias /home/myproject/web/mediafiles/;
    }

}
```

Create the following scripts in myproject directory:

createadmin.sh, setadminpw.py

Add the following to createadmin.sh:

```
#!/usr/bin/env bash

python manage.py createsuperuser --username admin --noinput --email admin@localhost
```

Add the following to setadminpw.py:

```
#!/usr/bin/env python

import os
import sys

import django

sys.path.append(".")
os.environ["DJANGO_SETTINGS_MODULE"] = "myproject.settings"

django.setup()

from django.contrib.auth.models import User # noqa: E402

admin_user = User.objects.get(username="admin")
admin_user.set_password("admin")
admin_user.save()
```

Create the following scripts:

getdeps.sh, dev-up.sh, prod-up.sh

Add the following to getdeps.sh:

```
#!/usr/bin/env bash

APP="myproject"
REQUIREMENTS="${APP}/requirements.txt"

function main() {
    pip-compile -o ${REQUIREMENTS} &&
    pip-sync ${REQUIREMENTS}
}

main;
```

Add the following to dev-up.sh:

```
#!/usr/bin/env bash

docker-compose up --build
```

Add the following to prod-up.sh:

```
#!/usr/bin/env bash

docker-compose -f docker-compose.prod.yml up --build
```

Run:

```
chmod +x *.sh
chmod +x myproject/*.sh
./getdeps.sh
./dev-up.sh
```

Have a look at http://localhost:8000 and admin

```
docker-compose down
```

Run:

```
./prod-up.sh
```

Have a look at http://localhost and admin

To stop:

```
docker-compose down
```
