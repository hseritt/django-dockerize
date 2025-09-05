#!/usr/bin/env bash

poetry export --with dev -f requirements.txt --output $DJANGO_PROJECT_NAME/requirements.txt
docker compose -f docker-compose.prod.yml down -v
docker compose -f docker-compose.prod.yml up --remove-orphans --build --force-recreate
