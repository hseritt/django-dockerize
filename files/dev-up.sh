#!/usr/bin/env bash

poetry export --with dev -f requirements.txt --output $DJANGO_PROJECT_NAME/requirements.txt
docker compose up --remove-orphans --build --force-recreate
