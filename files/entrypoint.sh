#!/bin/sh

if [ "$DATABASE" = "postgres" ]
then
    echo "Waiting for postgres..."

    while ! nc -z $SQL_HOST $SQL_PORT; do
      sleep 0.1
    done

    echo "PostgreSQL started"
fi

# python manage.py flush --no-input
python manage.py migrate
sh createadmin.sh
python setadminpw.py
python manage.py collectstatic --no-input
python manage.py diffsettings --all

exec "$@"
