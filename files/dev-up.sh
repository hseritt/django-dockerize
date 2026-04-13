#!/usr/bin/env bash

uv self update 2>/dev/null || pip install --upgrade uv
uv export --no-hashes -o $DJANGO_PROJECT_NAME/requirements.txt
docker compose up --remove-orphans --build --force-recreate -d

trap 'echo -e "\nEnter dc stop to stop containers."' SIGINT
docker compose logs -f
