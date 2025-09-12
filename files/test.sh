#!/usr/bin/env bash

clear

echo "Running local tests..."
sleep 0.5

poetry run pre-commit run isort --all-files &&
poetry run pre-commit run runflake8 --all-files &&
poetry run pre-commit run runtests --all-files --verbose &&
poetry run pre-commit run coverage --all-files
