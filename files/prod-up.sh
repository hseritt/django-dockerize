#!/usr/bin/env bash

clear
poetry export --with dev -f requirements.txt --output requirements.txt
cp requirements.txt $DJANGO_PROJECT_NAME/requirements.txt
docker compose -f docker-compose.prod.yml down -v
docker compose -f docker-compose.prod.yml up --remove-orphans --build --force-recreate
